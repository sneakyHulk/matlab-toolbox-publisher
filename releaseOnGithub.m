function releaseOnGithub(owner, repo, version, name, description, path_to_toolbox, token)
%releaseOnGithub Creates a GitHub release and uploads a .mltbx file as a GitHub release asset.
%   Inputs:
%       owner           - GitHub username (char or string)
%       repo            - GitHub repository name (char or string)
%       version         - Version of toolbox (char or string), like 'v1.0.0'
%       name            - Name of the release (char or string)
%       description     - Description of release (char or string)
%       path_to_toolbox - Path to .mltbx file to upload
%       token           - GitHub personal access token (char or string)

isValidVersion = @(s) (ischar(s) || isstring(s)) && ~isempty(regexp(char(s), '^v\d+\.\d+\.\d+$', 'once'));

p = inputParser;
addRequired(p, 'owner', @(x) ischar(x) || isstring(x));
addRequired(p, 'repo', @(x) ischar(x) || isstring(x));
addRequired(p, 'version', isValidVersion);
addRequired(p, 'name', @(x) ischar(x) || isstring(x));
addRequired(p, 'description', @(x) ischar(x) || isstring(x));
addRequired(p, 'path_to_toolbox', @(x) (ischar(x) || isstring(x)) && isfile(x));
addRequired(p, 'token', @(x) ischar(x) || isstring(x));

parse(p, owner, repo, version, name, description, path_to_toolbox, token);

releaseID = createAGithubRelease(owner, repo, version, name, description, token);
uploadToolboxToGithub(owner, repo, releaseID, path_to_toolbox, token);

end