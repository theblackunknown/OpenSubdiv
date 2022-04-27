

set(ICC_LIBRARIES)

function(osd_target_link_system_libraries target)

    # Intel's icc compiler requires some libraries linked
    if(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
        # Lazy load 
        list(LENGTH ICC_LIBRARIES ICC_LIBRARIES_LENGTH)
        if(ICC_LIBRARIES_LENGTH EQUAL 0)
            if(CMAKE_SIZEOF_VOID_P MATCHES "8")
                set(ICC_LIB_ARCH "intel64")
            elseif(CMAKE_SIZEOF_VOID_P MATCHES "4")
                set(ICC_LIB_ARCH "ia32")
            endif()

            set(ICC_LIBRARIES_LOCAL)

            foreach (ICC_LIB iomp5 irng intlc)
                find_library( ICC_${ICC_LIB}
                    NAMES
                        ${ICC_LIB}
                    HINTS
                        ${ICC_LOCATION}
                    PATHS
                        /opt/intel/lib/
                    PATH_SUFFIXES
                        ${ICC_LIB_ARCH}
                        lib/${ICC_LIB_ARCH}
                )

                if (ICC_${ICC_LIB})
                    list(APPEND ICC_LIBRARIES_LOCAL ${ICC_${ICC_LIB}})
                else()
                    message( FATAL_ERROR "${ICC_${ICC_LIB}} library not found - required by icc" )
                endif()

            endforeach()
            set(ICC_LIBRARIES ${ICC_LIBRARIES_LOCAL} PARENT_SCOPE)
        endif()

        target_link_libraries(${target}
            PRIVATE
                ${ICC_LIBRARIES}
        )
    endif()

    if(MSVC_STATIC_CRT)
        set_property(TARGET ${target} PROPERTY
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>"
        )
    else()
        set_property(TARGET ${target} PROPERTY
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL"
        )
    endif()
endfunction()
