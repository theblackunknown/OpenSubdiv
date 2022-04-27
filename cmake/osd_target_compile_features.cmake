function(osd_target_compile_features target)
    if( METAL_FOUND )
        target_compile_features(${target}
            PUBLIC
                cxx_std_14
        )
        set_target_properties(${target}
            PROPERTIES
                CXX_STANDARD          14
                CXX_STANDARD_REQUIRED ON
                CXX_EXTENSIONS        OFF
        )
    else()
        target_compile_features(${target}
            PUBLIC
                cxx_std_11
        )
        set_target_properties(${target}
            PROPERTIES
                CXX_STANDARD          11
                CXX_STANDARD_REQUIRED ON
                CXX_EXTENSIONS        OFF
        )
    endif()
endfunction()
