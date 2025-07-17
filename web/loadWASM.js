/* ©2025 FRINKnet & Friends - MIT LICENSE */
((WASM,loadWASM)=>WASM?loadWASM(WASM):module?.exports=loadWASM)(new URL(document.currentScript.src).hash,WASM=>WebAssembly.instantiateStreaming(fetch(`/wasm/${WASM}.wasm`),{env:{eval:(p,l)=>new Function(new TextDecoder().decode(new Uint8Array(WASM.exports.memory.buffer,p,l)))()}}).then(M=>(WASM=M.instance,WASM.exports.init(),WASM)))
