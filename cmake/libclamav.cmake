if(MINGW)
    set(OPENSSL_LIBRARY_PATH ${3RDPARTY_DIR}/openssl/lib/mingw/${CLAMAV_ARCH})
elseif(MSVC)
    set(OPENSSL_LIBRARY_PATH ${3RDPARTY_DIR}/openssl/lib/msvc/${CLAMAV_ARCH})
else()
    message(FATAL_ERROR "Unsupported compiler")
endif()

find_library(OPENSSL_SSL_LIBRARY
    NAMES ssl libssl
    HINTS ${OPENSSL_LIBRARY_PATH}
)

find_library(OPENSSL_CRYPTO_LIBRARY
    NAMES crypto libcrypto
    HINTS ${OPENSSL_LIBRARY_PATH}
)

file(GLOB libclamav_sources
    ${CLAMAV_DIR}/libclamav/*.c
    ${CLAMAV_DIR}/libclamav/7z/*.c
    ${CLAMAV_DIR}/libclamav/lzw/*.c
    ${CLAMAV_DIR}/libclamav/nsis/*.c
    ${CLAMAV_DIR}/libclamav/regex/*.c
    ${CLAMAV_DIR}/libclamav/tomsfastmath/*/*.c
    ${CLAMAV_DIR}/libclamav/jsparse/js-norm.c)
list(REMOVE_ITEM libclamav_sources
    ${CLAMAV_DIR}/libclamav/others.c
    ${CLAMAV_DIR}/libclamav/regex/engine.c
    ${CLAMAV_DIR}/libclamav/bytecode_nojit.c
    ${CLAMAV_DIR}/libclamav/tomsfastmath/misc/fp_ident.c)

file(GLOB libclamav_win32_sources ${CLAMWIN_DIR}/src/dllmain/*.c)
if(MINGW)
    list(APPEND libclamav_win32_sources ${CLAMWIN_DIR}/src/dllmain/pthread-mingw.c)
else()
    list(APPEND libclamav_win32_sources ${3RDPARTY_DIR}/pthreads/pthread.c)
endif()

file(GLOB_RECURSE libclamav_win32_headers ${CLAMWIN_DIR}/include/*.h)

source_group("Win32 Files" FILES ${libclamav_win32_sources})

add_library(libclamav SHARED
    ${libclamav_win32_headers}
    ${libclamav_sources}
    ${libclamav_win32_sources}
    ${CLAMWIN_DIR}/resources/libclamav.rc
    ${CLAMWIN_DIR}/libclamav.def
)

set_target_properties(libclamav PROPERTIES DEFINE_SYMBOL LIBCLAMAV_EXPORTS PREFIX "" OUTPUT_NAME libclamav)
target_include_directories(libclamav PRIVATE ${CLAMWIN_INCLUDES})
target_compile_definitions(libclamav PRIVATE ${CLAMWIN_DEFINES})
target_compile_options(libclamav PRIVATE $<$<C_COMPILER_ID:MSVC>:/wd4267 /wd4333 /wd4334>)

target_link_libraries(libclamav PRIVATE
    zlib
    bzip2
    pcre2
    json-c
    libxml2
    clammspack
    gnulib
    ${OPENSSL_SSL_LIBRARY}
    ${OPENSSL_CRYPTO_LIBRARY}
    ws2_32
)

if(MSVC)
    set_target_properties(libclamav PROPERTIES PUBLIC_HEADER ${CLAMAV_DIR}/libclamav/clamav.h)
endif()

list(APPEND CLAMAV_INSTALL_TARGETS libclamav)

install(FILES ${3RDPARTY_DIR}/openssl/LICENSE DESTINATION ${CMAKE_INSTALL_PREFIX}/copyright RENAME COPYING.openssl)
install(FILES ${3RDPARTY_DIR}/pthreads/COPYING DESTINATION ${CMAKE_INSTALL_PREFIX}/copyright RENAME COPYING.pthreads-win32)
install(FILES ${3RDPARTY_DIR}/gnulib/COPYING DESTINATION ${CMAKE_INSTALL_PREFIX}/copyright RENAME COPYING.gnulib)
install(FILES ${3RDPARTY_DIR}/libunicows/license.txt DESTINATION ${CMAKE_INSTALL_PREFIX}/copyright RENAME COPYING.libunicows)
