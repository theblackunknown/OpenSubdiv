function(osd_target_warning_options target)
    target_compile_options(${target}
        PRIVATE
            $<$<CXX_COMPILER_ID:Clang,AppleClang,GNU,Intel>:
                # Turn on all warnings
                -Wall
                -Wextra

                # HBR uses the offsetof macro on a templated struct, which appears
                # to spuriously set off this warning in both gcc and Clang
                -Wno-invalid-offsetof

                # HBR uses unions as an optimization for its memory allocation.
                # Type casting between union members breaks strict aliasing rules from
                # gcc 4.4.1 versions onwards. We disable the warning but keep aliasing
                # optimization.
                -Wno-strict-aliasing
            >
            $<$<CXX_COMPILER_ID:Intel>:
                -w2
                -wd1572
                -wd1418
                -wd981
                -wd383
                -wd193
                -wd444
            >
            $<$<CXX_COMPILER_ID:Clang,AppleClang>:
                # FAR and OSD have templated virtual function implementations that trigger
                # a lot of hidden virtual function overloads (some of them spurious).
                # Disable those for now in Clang.
                -Wno-overloaded-virtual
            >
            $<$<CXX_COMPILER_ID:MSVC>:
                /W3     # Use warning level recommended for production purposes.
                # /WX     # Treat all compiler warnings as errors.

                # warning C4005: macro redefinition
                /wd4005

                # these warnings are being triggered from inside VC's header files
                # warning C4350: behavior change: 'member1' called instead of 'member2'
                /wd4350
                # warning C4548: expression before comma has no effect; expected expression with side-effect
                /wd4548
            >
    )
    target_link_options(${target}
        PRIVATE
            $<$<CXX_COMPILER_ID:MSVC>:
                # Turn off a duplicate LIBCMT linker warning
                /NODEFAULTLIB:libcmt.lib
            >
    )
endfunction()
