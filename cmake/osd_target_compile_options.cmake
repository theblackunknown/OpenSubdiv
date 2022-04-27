function(osd_target_compile_options target)
    target_compile_options(${target}
        PRIVATE
            $<$<AND:$<PLATFORM_ID:Linux>,$<COMPILE_LANGUAGE:CUDA>>:
                -Xcompiler -fPIC
            >
            # The /Zc:inline option strips out the "arch_ctor_<name>" symbols used for
            # library initialization by ARCH_CONSTRUCTOR starting in Visual Studio 2019, 
            # causing release builds to fail. Disable the option for this and later 
            # versions.
            # 
            # For more details, see:
            # https://developercommunity.visualstudio.com/content/problem/914943/zcinline-removes-extern-symbols-inside-anonymous-n.html
            $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_GREATER_EQUAL:$<CXX_COMPILER_VERSION>,1920>>:/Zc:inline->
            $<$<AND:$<CXX_COMPILER_ID:MSVC>,$<VERSION_LESS:$<CXX_COMPILER_VERSION>,1920>>:/Zc:inline>

            $<$<COMPILE_LANGUAGE:OBJCXX>:-fobjc-arc>
    )
endfunction()
