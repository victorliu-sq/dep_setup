find_path(HdrHistogram_INCLUDE_DIR
        NAMES hdr_histogram.h
        PATH_SUFFIXES hdr
)

find_library(HdrHistogram_LIBRARY
        NAMES hdr_histogram_static
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HdrHistogram
        REQUIRED_VARS HdrHistogram_INCLUDE_DIR HdrHistogram_LIBRARY
)

if (HdrHistogram_FOUND AND NOT TARGET HdrHistogram::HdrHistogram)
    add_library(HdrHistogram::HdrHistogram STATIC IMPORTED)
    set_target_properties(HdrHistogram::HdrHistogram PROPERTIES
            IMPORTED_LOCATION "${HdrHistogram_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${HdrHistogram_INCLUDE_DIR};${HdrHistogram_INCLUDE_DIR}/.."
            INTERFACE_LINK_LIBRARIES "ZLIB::ZLIB;m"
    )
endif ()

mark_as_advanced(HdrHistogram_INCLUDE_DIR HdrHistogram_LIBRARY)
