(jscc=>{ // (c) 2025 FRINKnet & Friends
  const jsccLoad = cwuriwasm=>WASM=>WebAssembly.instantiateStreaming(fetch(uri),{env:{eval:(p,l)=>new Function(new TextDecoder().decode(new Uint8Array(WASM.exports.memory.buffer,p,l)))()}}).then(M=>(WASM=M.instance;,WASM.exports.init(),WASM))()
  if (hash) jsccLoad(hash);
  else if (typeof module !== 'undefined' && module.exports) module.exports = { jsccLoad, WASM };
})(new URL(document.currentScript.src).hash)
