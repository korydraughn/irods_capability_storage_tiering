set(POLICY_NAME "unified_storage_tiering")

string(REPLACE "_" "-" POLICY_NAME_HYPHENS ${POLICY_NAME})
set(IRODS_PACKAGE_COMPONENT_POLICY_NAME ${POLICY_NAME_HYPHENS})
set(TOUPPER IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE ${IRODS_PACKAGE_COMPONENT_POLICY_NAME})

set(TARGET_NAME "${PROJECT_NAME}-${POLICY_NAME}")

set(
  IRODS_PLUGIN_POLICY_COMPILE_DEFINITIONS
  RODS_SERVER
  ENABLE_RE
  )

set(
  IRODS_PLUGIN_POLICY_LINK_LIBRARIES
  irods_server
  )

add_library(
    ${TARGET_NAME}
    MODULE
    ${CMAKE_SOURCE_DIR}/lib${TARGET_NAME}.cpp
    ${CMAKE_SOURCE_DIR}/storage_tiering.cpp
    ${CMAKE_SOURCE_DIR}/storage_tiering_configuration.cpp
    ${CMAKE_SOURCE_DIR}/storage_tiering_utilities.cpp
    ${CMAKE_SOURCE_DIR}/data_verification_utilities.cpp
    )

target_include_directories(
    ${TARGET_NAME}
    PRIVATE
    ${IRODS_INCLUDE_DIRS}
    ${IRODS_EXTERNALS_FULLPATH_ARCHIVE}/include
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/include
    ${IRODS_EXTERNALS_FULLPATH_JANSSON}/include
    ${IRODS_EXTERNALS_FULLPATH_JSON}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    )

target_link_libraries(
    ${TARGET_NAME}
    PRIVATE
    ${IRODS_PLUGIN_POLICY_LINK_LIBRARIES}
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_filesystem.so
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_regex.so
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_system.so
    ${IRODS_EXTERNALS_FULLPATH_BOOST}/lib/libboost_thread.so
    ${OPENSSL_CRYPTO_LIBRARY}
    irods_common
    pthread
    )

target_compile_definitions(${TARGET_NAME} PRIVATE ${IRODS_PLUGIN_POLICY_COMPILE_DEFINITIONS} ${IRODS_COMPILE_DEFINITIONS} BOOST_SYSTEM_NO_DEPRECATED)
target_compile_options(${TARGET_NAME} PRIVATE -Wno-write-strings)
set_property(TARGET ${TARGET_NAME} PROPERTY CXX_STANDARD ${IRODS_CXX_STANDARD})

install(
  TARGETS
  ${TARGET_NAME}
  LIBRARY
  DESTINATION usr/lib/irods/plugins/rule_engines
  COMPONENT ${IRODS_PACKAGE_COMPONENT_POLICY_NAME}
  )

install(
  FILES
  ${CMAKE_SOURCE_DIR}/packaging/test_plugin_unified_storage_tiering.py
  DESTINATION ${IRODS_HOME_DIRECTORY}/scripts/irods/test
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
  COMPONENT ${IRODS_PACKAGE_COMPONENT_POLICY_NAME}
  )

install(
  FILES
  ${CMAKE_SOURCE_DIR}/packaging/run_unified_storage_tiering_plugin_test.py
  DESTINATION ${IRODS_HOME_DIRECTORY}/scripts
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
  COMPONENT ${IRODS_PACKAGE_COMPONENT_POLICY_NAME}
  )

install(
  FILES
  ${CMAKE_SOURCE_DIR}/example_unified_tiering_invocation.r
  DESTINATION ${IRODS_HOME_DIRECTORY}
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
  COMPONENT ${IRODS_PACKAGE_COMPONENT_POLICY_NAME}
  )

set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/packaging/postinst_tiering;")
set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_SOURCE_DIR}/packaging/postinst_tiering")

set(CPACK_DEBIAN_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_NAME ${TARGET_NAME})
set(CPACK_DEBIAN_${IRODS_PACKAGE_COMPONENT_POLICY_NAME_UPPERCASE}_PACKAGE_DEPENDS "${IRODS_PACKAGE_DEPENDENCIES_STRING}, irods-server (= ${IRODS_VERSION}), irods-runtime (= ${IRODS_VERSION}), libc6, irods-rule-engine-plugin-apply-access-time-2.5.0, irods-rule-engine-plugin-data-movement-2.5.0, irods-rule-engine-plugin-data-replication-2.5.0, irods-rule-engine-plugin-data-verification-2.5.0")

set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_NAME ${TARGET_NAME})
if (IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "centos" OR IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "centos linux")
    set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_REQUIRES "${IRODS_PACKAGE_DEPENDENCIES_STRING}, irods-server = ${IRODS_VERSION}, irods-runtime = ${IRODS_VERSION}, openssl")
elseif (IRODS_LINUX_DISTRIBUTION_NAME STREQUAL "opensuse")
    set(CPACK_RPM_${IRODS_PACKAGE_COMPONENT_POLICY_NAME}_PACKAGE_REQUIRES "${IRODS_PACKAGE_DEPENDENCIES_STRING}, irods-server = ${IRODS_VERSION}, irods-runtime = ${IRODS_VERSION}, libopenssl1_0_0")
endif()
