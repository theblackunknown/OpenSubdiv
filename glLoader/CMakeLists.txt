#
#   Copyright 2020 Pixar
#
#   Licensed under the Apache License, Version 2.0 (the "Apache License")
#   with the following modification; you may not use this file except in
#   compliance with the Apache License and the following modification to it:
#   Section 6. Trademarks. is deleted and replaced with:
#
#   6. Trademarks. This License does not grant permission to use the trade
#      names, trademarks, service marks, or product names of the Licensor
#      and its affiliates, except as required to comply with Section 4(c) of
#      the License and to reproduce the content of the NOTICE file.
#
#   You may obtain a copy of the Apache License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the Apache License with the above modification is
#   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#   KIND, either express or implied. See the Apache License for the specific
#   language governing permissions and limitations under the Apache License.
#

# if( APPLE OR UNIX )
#     add_definitions(-fPIC)
# endif()

list(APPEND GLLOADER_SOURCE_FILES
    glLoader.cpp
    glApi.cpp
)

list(APPEND GLLOADER_HEADER_FILES
    glLoader.h
    glApi.h
    khrplatform.h
)

# include_directories(
#     "${OPENGL_LOADER_INCLUDE_DIRS}"
# )

# list(APPEND PLATFORM_LIBRARIES
#     "${OPENGL_LOADER_LIBRARIES}"
# )

add_library(glLoader_obj
    OBJECT
        ${GLLOADER_SOURCE_FILES}
        ${GLLOADER_HEADER_FILES}
)

osd_target_compile_definitions(glLoader_obj)
osd_target_compile_features(glLoader_obj)
osd_target_compile_options(glLoader_obj)
osd_target_include_directories(glLoader_obj)
osd_target_link_system_libraries(glLoader_obj)
osd_target_warning_options(glLoader_obj)

target_include_directories(glLoader_obj
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}
)

if( GLEW_FOUND AND NOT NO_GLEW )
    target_link_libraries(glLoader_obj
        PUBLIC
            GLEW::GLEW
            OpenGL::GL
            ${CMAKE_DL_LIBS}
    )
elseif( OPENGL_FOUND AND NOT NO_OPENGL )
    target_link_libraries(glLoader_obj
        PUBLIC
            OpenGL::GL
            ${CMAKE_DL_LIBS}
    )
endif()