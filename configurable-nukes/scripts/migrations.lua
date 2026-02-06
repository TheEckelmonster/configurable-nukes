local versions = {
    { major = 0, minor = 5, bug_fix = 0, },
    { major = 0, minor = 6, bug_fix = 0, },
    { major = 0, minor = 7, bug_fix = 0, },
    { major = 0, minor = 7, bug_fix = 1, },
    { major = 0, minor = 7, bug_fix = 4, },
    { major = 0, minor = 9, bug_fix = 5, },
}

local return_val = {}
for _, version in ipairs(versions) do
    return_val[version] = require(
        "migrations"
        .. "." .. version.major
        .. "-" .. version.minor
        .. "-" .. version.bug_fix
    )
end

return return_val