/* ©2025 FRINKnet & Friends - MIT LICENSE */
((WASM, loadWASM) => WASM.hash ? loadWASM(WASM.hash.slice(1), WASM.search === "?secure") : module?.exports = loadWASM)(
  new URL(document.currentScript.src),
  (WASM, X) => WebAssembly.instantiateStreaming(
    fetch(`/wasm/${WASM}.wasm`), X === 1? {} : Object.assign({
      env: {
        eval: (p, l) => new Function(new TextDecoder().decode(new Uint8Array(WASM.exports.memory.buffer, p, l)))()
      }
    }, X)
  ).then(
    M => (WASM = M.instance, (X?.init||WASM.exports.js_init)?.(), WASM)
  )
)
