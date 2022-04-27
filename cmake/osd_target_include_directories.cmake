function(osd_target_include_directories target)
    target_include_directories(${target}
        PRIVATE
            ${OpenSubdiv_SOURCE_DIR}
            ${OpenSubdiv_SOURCE_DIR}/glLoader
    )
endfunction()
