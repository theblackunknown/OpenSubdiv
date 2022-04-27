function(osd_target_compile_definitions target)
    target_compile_definitions(${target}
        PRIVATE
            "OPENSUBDIV_VERSION_STRING=\"${OSD_SONAME}\""

            $<IF:$<BOOL:${GLEW_FOUND}>,OSD_USES_GLEW,OSD_USES_INTERNAL_GLAPILOADER>

            $<$<BOOL:${OPENMP_FOUND}>:OPENSUBDIV_HAS_OPENMP>

            $<$<BOOL:${TBB_FOUND}>:OPENSUBDIV_HAS_TBB>

            $<$<BOOL:${OPENGLES_FOUND}>:OPENSUBDIV_HAS_OPENGLES>

            $<$<BOOL:${OPENCL_FOUND}>:OPENSUBDIV_HAS_OPENCL>

            $<$<BOOL:${CLEW_FOUND}>:OPENSUBDIV_HAS_CLEW>

            $<$<BOOL:${OPENCL_CL_D3D11_H_FOUND}>:
                OPENSUBDIV_HAS_OPENCL_DX_INTEROP
                OPENSUBDIV_HAS_CL_D3D11_H
            >
            $<$<BOOL:${OPENCL_CL_D3D11_EXT_H_FOUND}>:
                OPENSUBDIV_HAS_OPENCL_DX_INTEROP
                OPENSUBDIV_HAS_CL_D3D11_EXT_H
            >
            $<$<BOOL:${CUDA_FOUND}>:
                OPENSUBDIV_HAS_CUDA
                CUDA_ENABLE_DEPRECATED=0
            >
            $<$<BOOL:${PTEX_FOUND}>:OPENSUBDIV_HAS_PTEX>

            # note : (GLSL transform feedback kernels require GL 4.2)
            $<$<BOOL:${OPENGL_4_2_FOUND}>:OPENSUBDIV_HAS_GLSL_TRANSFORM_FEEDBACK>
            # note : (GLSL compute shader kernels require GL 4.3)
            $<$<BOOL:${OPENGL_4_3_FOUND}>:OPENSUBDIV_HAS_GLSL_COMPUTE>

            $<$<VERSION_GREATER_EQUAL:${GLFW_VERSION},3>:GLFW_VERSION_3>

            $<$<BOOL:${DXSDK_FOUND}>:OPENSUBDIV_HAS_DX11SDK>

            $<$<BOOL:${OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES}>:OPENSUBDIV_GREGORY_EVAL_TRUE_DERIVATIVES>

            $<$<CXX_COMPILER_ID:MSVC>:
                # Make sure the constants in <math.h> get defined.
                _USE_MATH_DEFINES

                # Do not enforce MSVC's safe CRT replacements.
                _CRT_SECURE_NO_WARNINGS

                # Make sure WinDef.h does not define min and max macros which
                # will conflict with std::min() and std::max().
                NOMINMAX 

                # Disable checked iterators and iterator debugging.  Visual Studio
                # 2008 does not implement std::vector::data(), so we need to take the
                # address of std::vector::operator[](0) to get the memory location of
                # a vector's underlying data storage.  This does not work for an empty
                # vector if checked iterators or iterator debugging is enabled.

                # XXXX manuelk : we can't force SECURE_SCL to 0 or client code has
                # problems linking against OSD if their build is not also
                # overriding SSCL to the same value.
                # See : http://msdn.microsoft.com/en-us/library/vstudio/hh697468.aspx
                #_SECURE_SCL=0
                #_HAS_ITERATOR_DEBUGGING=0
            >
    )
    if (OPENGL_FOUND AND NOT IOS)
        target_compile_definitions(${target}
            PRIVATE
                OPENSUBDIV_HAS_OPENGL
        )
    endif()
    if(${SIMD} MATCHES "AVX")
        target_compile_options(${target}
            PRIVATE
                -xAVX
        )
    endif()
    if(NOT NO_CUDA)
        if(NOT OSD_CUDA_NVCC_FLAGS)
            if(CUDAToolkit_VERSION VERSION_LESS 6)
                set_property(TARGET ${target} PROPERTY CUDA_ARCHITECTURES 11)
            else()
                set_property(TARGET ${target} PROPERTY CUDA_ARCHITECTURES 20)
            endif()
        endif()
    endif()
endfunction()
