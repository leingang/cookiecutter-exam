-- This is a Lua script based on the 'vc' shell script for TeX.
-- The original shell script is Public Domain.
{% raw %}
CRLF = "\n"

-- Parse command line options
local full = 0
local mod = false

local function parse_args(args)
    for _, arg in ipairs(args) do
        if arg == "-f" then
            full = 1
        elseif arg == "-m" then
            mod = true
        else
            print("usage: vc [-f] [-m]")
            os.exit(1)
        end
    end
end

-- Run a system command and return the output
local function run_command(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result
end

local function process_git_log(input, full)
    local result = {}

    -- Extract relevant fields, stopping at newlines
    local Hash = input:match("Hash: ([^\n]+)")
    local AbrHash = input:match("AbrHash: ([^\n]+)")
    local ParentHashes = input:match("ParentHashes: ([^\n]+)")
    local AbrParentHashes = input:match("AbrParentHashes: ([^\n]+)")
    local AuthorName = input:match("AuthorName: ([^\n]+)")
    local AuthorEmail = input:match("AuthorEmail: ([^\n]+)")
    local AuthorDate = input:match("AuthorDate: ([^\n]+)")
    local CommitterName = input:match("CommitterName: ([^\n]+)")
    local CommitterEmail = input:match("CommitterEmail: ([^\n]+)")
    local CommitterDate = input:match("CommitterDate: ([^\n]+)")

    -- Date and time formatting
    local LongDate = CommitterDate:sub(1, 25)
    local DateRAW = LongDate:sub(1, 10)
    local DateISO = DateRAW
    local DateTEX = DateRAW:gsub("-", "/")
    local Time = LongDate:sub(12,-1)

    -- Output TeX macros
    local tex = string.format([[
%%%%%% This file has been generated by the vc bundle for TeX.
%%%%%% Do not edit this file!
%%%%%%

%%%%%% Define Git specific macros.
\gdef\GITHash{%s}%%
\gdef\GITAbrHash{%s}%%
\gdef\GITParentHashes{%s}%%
\gdef\GITAbrParentHashes{%s}%%
\gdef\GITAuthorName{%s}%%
\gdef\GITAuthorEmail{%s}%%
\gdef\GITAuthorDate{%s}%%
\gdef\GITCommitterName{%s}%%
\gdef\GITCommitterEmail{%s}%%
\gdef\GITCommitterDate{%s}%%

%%%%%% Define generic version control macros.
\gdef\VCRevision{\GITAbrHash}%%
\gdef\VCAuthor{\GITAuthorName}%%
\gdef\VCDateRAW{%s}%%
\gdef\VCDateISO{%s}%%
\gdef\VCDateTEX{%s}%%
\gdef\VCTime{%s}%%
\gdef\VCModifiedText{\textcolor{red}{with local modifications!}}%%

%%%%%% Assume clean working copy.
\gdef\VCModified{0}%%
\gdef\VCRevisionMod{\VCRevision}%%
    ]], Hash, AbrHash, ParentHashes, AbrParentHashes, 
        AuthorName, AuthorEmail, AuthorDate, 
        CommitterName, CommitterEmail, 
        CommitterDate, DateRAW, DateISO, DateTEX, Time)
    return tex
end

local function process_git_tag(input)
    local result = {}

    local tag, commits = input:match("([%w%.%-]+)%-(%d+)%-.+")
    commits = tonumber(commits) or 0

    -- Output TeX macros for the tag
    return string.format([[
%%%%%% Define Git tag macro.
\gdef\GITTag{%s}%%
\gdef\GITCommitsSinceTag{%s}%%
    ]],tag or "",commits)
end

local function process_git_status(input)
    local result = {}
    local modified = false

    -- Check if there are any lines in the status output (non-empty input means modifications)
    for line in input:gmatch("[^\n]+") do
        -- If any line exists, it means the working directory has changes
        if #line > 0 then
            modified = true
            break
        end
    end

    -- Output TeX macros
    table.insert(result, "%%% Is working copy modified?")
    if modified then
        table.insert(result, "\\gdef\\VCModified{1}%")
        table.insert(result, "\\gdef\\VCRevisionMod{\\VCRevision~\\VCModifiedText}%")
    else
        table.insert(result, "\\gdef\\VCModified{0}%")
        table.insert(result, "\\gdef\\VCRevisionMod{\\VCRevision}%")
    end

    -- Return result as a single string
    return table.concat(result, "\n")
end



-- Query all info from git log
local function query_git_info()
    local logformat = [[
Hash: %H
AbrHash: %h
ParentHashes: %P
AbrParentHashes: %p
AuthorName: %an
AuthorEmail: %ae
AuthorDate: %ai
CommitterName: %cn
CommitterEmail: %ce
CommitterDate: %ci
]]

    local git_log = process_git_log(run_command('git --no-pager log -1 HEAD --pretty=format:"' .. logformat .. '"' ),full)
    local git_describe = process_git_tag(run_command('git describe --tags'))

    -- Process the git log and tag info using external scripts (simulating the awk processing)
    local vc_tex = io.open("vc.tex", "w")
    vc_tex:write(git_log, CRLF)
    vc_tex:write(git_describe, CRLF)
    vc_tex:close()

    -- Query modification status of the working copy
    if mod then
        local git_status = process_git_status(run_command('git status --porcelain=v1'))
        local vc_tex_append = io.open("vc.tex", "a")
        vc_tex_append:write(git_status, CRLF)
        vc_tex_append:close()
    end
end

-- Main logic
parse_args(arg)
query_git_info()
{% endraw %}