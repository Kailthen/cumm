#!/bin/bash
set -e -u -x

function repair_wheel {
    wheel="$1"
    outpath="$2"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w "$outpath"
    fi
}

export CUMM_ENABLE_JIT=0
export CUMM_CUDA_ARCH_LIST="all"
# Compile wheels, we only support 3.6-3.10.
"/opt/python/cp36-cp36m/bin/pip" wheel /io/ --no-deps -w /io/wheelhouse_tmp
"/opt/python/cp37-cp37m/bin/pip" wheel /io/ --no-deps -w /io/wheelhouse_tmp
"/opt/python/cp38-cp38/bin/pip" wheel /io/ --no-deps -w /io/wheelhouse_tmp
"/opt/python/cp39-cp39/bin/pip" wheel /io/ --no-deps -w /io/wheelhouse_tmp
"/opt/python/cp310-cp310/bin/pip" wheel /io/ --no-deps -w /io/wheelhouse_tmp

# Bundle external shared libraries into the wheels
for whl in /io/wheelhouse_tmp/*.whl; do
    repair_wheel "$whl" /io/dist
done

rm -rf /io/wheelhouse_tmp