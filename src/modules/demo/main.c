#include "wacc.h"

JS_START
void main(void) {
	JS_CODE(
		Object.assign(document.body.style, {margin:0, overflow:"hidden"});
		const canvas = document.body.appendChild(document.createElement('canvas'));
		Object.assign(canvas.style, {position:"fixed", width:"100vw", height:"100vh"});
		const gl = canvas.getContext('webgl2');		window.gl = gl;  window.canvas = canvas;

		const resize = () => {
				canvas.width	= innerWidth	* devicePixelRatio;
				canvas.height = innerHeight * devicePixelRatio;
				gl.viewport(0, 0, canvas.width, canvas.height);
				if(WASM.exports.on_resize) WASM.exports.on_resize(canvas.width, canvas.height);
		};
		addEventListener('resize', resize);  resize();

		canvas.onmousemove = e => WASM.exports.on_mouse && WASM.exports.on_mouse(e.clientX, e.clientY);
		canvas.onmousedown = e => WASM.exports.on_click && WASM.exports.on_click(e.button,1);
		canvas.onmouseup	 = e => WASM.exports.on_click && WASM.exports.on_click(e.button,0);
		addEventListener('keydown', e => WASM.exports.on_key && WASM.exports.on_key(e.keyCode,1));
		addEventListener('keyup',		e => WASM.exports.on_key && WASM.exports.on_key(e.keyCode,0));

		(function loop(){ WASM.exports.frame(); requestAnimationFrame(loop); })();
	);
}

JS_EXPORT("frame")
void frame(void) {
		igNewFrame();
		igShowDemoWindow(NULL);
		igRender();
}
