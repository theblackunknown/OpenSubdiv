function(osd_target_link_cpu_dependencies_libraries target)
    target_link_libraries(${target}
        PRIVATE
            $<$<BOOL:${OPENMP_FOUND}>:OpenMP::OpenMP_CXX>
            $<$<BOOL:${TBB_FOUND}>:TBB::tbb>
    )
endfunction()
