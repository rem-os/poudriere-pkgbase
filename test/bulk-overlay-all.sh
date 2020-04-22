#! /bin/sh

ALL=1
OVERLAYS="overlay"
. common.bulk.sh

${SUDO} ${POUDRIEREPATH} -e ${POUDRIERE_ETC} bulk -n -CNt \
    -O "${OVERLAYS}" \
    -B "${BUILDNAME}" \
    -j "${JAILNAME}" -p "${PTNAME}" ${SETNAME:+-z "${SETNAME}"} \
    -a
assert 0 $? "Bulk should pass"

# Assert that we found the right misc/foo
ret=0
hash_get originspec-pkgname "misc/foo" pkgname || ret=$?
assert 0 "${ret}" "Cannot find pkgname for misc/foo"
assert "foo-OVERLAY-20161010" "${pkgname}" "misc/foo didn't find the overlay version"

# Assert that IGNOREDPORTS was populated by the framework right.
assert "ports-mgmt/poudriere-devel-IGNORED ports-mgmt/poudriere-devel-IGNORED-and-skipped misc/foo@IGNORED_OVERLAY" \
    "${IGNOREDPORTS-null}" "IGNOREDPORTS should match"

# Assert that skipped ports are right
assert "ports-mgmt/poudriere-devel-dep2-IGNORED ports-mgmt/poudriere-devel-dep-IGNORED" "${SKIPPEDPORTS-null}" "SKIPPEDPORTS should match"

# Assert the IGNOREd ports are tracked in .poudriere.ports.ignored
assert_ignored "${IGNOREDPORTS}"

# Assert that only listed packages are in poudriere.ports.queued as 'listed'
assert_queued "listed" "${LISTPORTS}"

# Assert the IGNOREd ports are tracked in .poudriere.ports.ignored
assert_ignored "${IGNOREDPORTS}"

# Assert that SKIPPED ports are right
assert_skipped "${SKIPPEDPORTS}"

# Assert that all expected dependencies are in poudriere.ports.queued (since
# they do not exist yet)
expand_origin_flavors "${LISTPORTS_NOIGNORED}" expanded_LISTPORTS_NOIGNORED
list_all_deps "${expanded_LISTPORTS_NOIGNORED}" ALL_EXPECTED
assert_queued "" "${ALL_EXPECTED}"

# Assert stats counts are right
assert_counts
