#ifndef JSCC_H
#define JSCC_H

// (c) 2025 FRINKnet & Friends - MIT licence

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int type;			    /* 0 number | 1 string | 2 bool | 3 array
				       4 object | 5 null   | 6 function       */
    union {
	double num;
	char  *str;
	int    bool_val;
	struct { void *ptr; int length; } array;
	int object_id;
	int func_id;
    } value;
} js_value;

// For functions exported to JS (i.e. make visible as WebAssembly exports)
#define JS_EXPOSE(name) __attribute__((used, export_name(name)))

// For functions imported from JS (i.e. declared extern in C)  
#define JS_EXTERN __attribute__((used)) extern

JS_EXTERN void eval(const char *code, int len, ...);
JS_EXTERN js_value *code(const char *code, int len, ...);
JS_EXTERN js_value *get(int object_id, const char *key);
JS_EXTERN void set(int object_id, const char *key, js_value *val);
JS_EXTERN js_value *execute(int func_id, ...);

#define JS_EVAL(code)	     eval(#code, sizeof(#code) - 1)
#define JS_CODE(code)	     code(#code, sizeof(#code) - 1)
#define JS_IMPORT(expr)      code("return " #expr, sizeof("return " #expr) - 1)
#define JS_GET(obj, key)     get((obj)->value.object_id, key)
#define JS_SET(obj, key, v)  set((obj)->value.object_id, key, v)
#define JS_EXECUTE(f, ...)   execute((f)->value.func_id, __VA_ARGS__)
#define JS_LENGTH(v)	     JS_GET((v), "length")

#define JS_NUMBER(v)   ((v) && (v)->type == 0 ? (v)->value.num	     : 0)
#define JS_STRING(v)   ((v) && (v)->type == 1 ? (v)->value.str	     : NULL)
#define JS_BOOLEAN(v)  ((v) && (v)->type == 2 ? (v)->value.bool_val  : 0)
#define JS_ARRAY(v)    ((v) && (v)->type == 3 ? (double*)(v)->value.array.ptr : NULL)
#define JS_OBJECT(v)   ((v) && (v)->type == 4 ? (v)->value.object_id : -1)
#define JS_FUNCTION(v) ((v) && (v)->type == 6 ? (v)->value.func_id   : -1)

static JS_EXPOSE("init")
void init(void) {
    JS_EVAL(
	/* registry buckets							 */
	WASM.objects   = [];
	WASM.functions = [];

	/* universal value-packing helper					 */
	WASM.pack = function(res){
	    const s  = WASM.exports.malloc(32);
	    const dv = new DataView(WASM.exports.memory.buffer, s, 32);
	    switch(typeof res){
		case 'number':
		    dv.setInt32 (0, 0, true);
		    dv.setFloat64(8, res, true);
		    break;
		case 'string': {
		    dv.setInt32(0, 1, true);
		    const p = WASM.exports.malloc(res.length + 1);
		    new Uint8Array(WASM.exports.memory.buffer, p, res.length + 1)
			.set(new TextEncoder().encode(res + '\0'));
		    dv.setInt32(8, p, true);
		    break;
		}
		case 'boolean':
		    dv.setInt32(0, 2, true);
		    dv.setInt32(8, res ? 1 : 0, true);
		    break;
		case 'object':
		    if(res === null){ dv.setInt32(0, 5, true); break; }
		    if(Array.isArray(res)){
			dv.setInt32(0, 3, true);
			const p  = WASM.exports.malloc(res.length * 8);
			const dv2= new DataView(WASM.exports.memory.buffer, p, res.length * 8);
			res.forEach((x,i)=>dv2.setFloat64(i*8, typeof x === 'number' ? x : NaN, true));
			dv.setInt32(8, p, true);
			dv.setInt32(12,res.length, true);
			break;
		    }
		    dv.setInt32(0, 4, true);
		    dv.setInt32(8, WASM.objects.length, true);
		    WASM.objects.push(res);
		    break;
		case 'function':
		    dv.setInt32(0, 6, true);
		    dv.setInt32(8, WASM.functions.length, true);
		    WASM.functions.push(res);
		    break;
		default:
		    dv.setInt32(0, 5, true);	   /* null / unsupported	*/
	    }
	    return s;
	};

	/* bridge functions delegate to pack()					 */
	WASM.code = function(ptr,len,...args){
	    const src = new TextDecoder()
			 .decode(new Uint8Array(WASM.exports.memory.buffer, ptr, len));
	    return WASM.pack((new Function(src))(...args));
	};

	WASM.execute = (fid, ...args) => WASM.pack(WASM.functions[fid](...args));

	WASM.get = function(oid, kp){
	    const mem = new Uint8Array(WASM.exports.memory.buffer, kp);
	    const key = new TextDecoder().decode(mem.subarray(0, mem.indexOf(0)));
	    const obj = WASM.objects[oid];
	    if(!obj) return WASM.pack(null);
	    const v = obj[key];
	    if(typeof v === 'function'){
		const fid = WASM.functions.length;
		WASM.functions.push(v.bind(obj));
		return WASM.pack(WASM.functions[fid]);
	    }
	    return WASM.pack(v);
	};

	WASM.set = function(oid, kp, val){
	    const mem = new Uint8Array(WASM.exports.memory.buffer, kp);
	    const key = new TextDecoder().decode(mem.subarray(0, mem.indexOf(0)));
	    const obj = WASM.objects[oid];
	    if(obj){
		const dv = new DataView(WASM.exports.memory.buffer, val, 32);
		switch(dv.getInt32(0, true)){
		    case 0: obj[key] = dv.getFloat64(8,true); break;
		    case 1: obj[key] = new TextDecoder()
				   .decode(new Uint8Array(WASM.exports.memory.buffer,
							   dv.getInt32(8,true)))
				   .replace(/\0.*$/,'');			break;
		    case 2: obj[key] = !!dv.getInt32(8,true);			 break;
		    default: /* arrays/objects left as exercise */		 ;
		}
	    }
	};
    );
    
    if (WASM.exports.main) WASM.exports.main();
}

#ifdef __cplusplus
}
#endif

#endif /* JSCC_H */

