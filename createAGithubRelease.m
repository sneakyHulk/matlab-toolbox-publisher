function releaseID = createAGithubRelease(owner, repo, version, name, description, token)
%createAGithubRelease Creates a GitHub release.
%   Inputs:
%       owner           - GitHub username (char or string)
%       repo            - GitHub repository name (char or string)
%       version         - Version of toolbox (char or string), like 'v1.0.0'
%       name            - Name of the release (char or string)
%       description     - Description of release (char or string)
%       token           - GitHub personal access token (char or string)
%   Outputs:
%       releaseID       - The releaseID edit the release further i.e.
%                           upload an asset

isValidVersion = @(s) (ischar(s) || isstring(s)) && ~isempty(regexp(char(s), '^v\d+\.\d+\.\d+$', 'once'));

p = inputParser;
addRequired(p, 'owner', @(x) ischar(x) || isstring(x));
addRequired(p, 'repo', @(x) ischar(x) || isstring(x));
addRequired(p, 'version', isValidVersion);
addRequired(p, 'name', @(x) ischar(x) || isstring(x));
addRequired(p, 'description', @(x) ischar(x) || isstring(x));
addRequired(p, 'token', @(x) ischar(x) || isstring(x));

parse(p, owner, repo, version, name, description, token);

%% Create the release
% Reference see https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#create-a-release

disp("Creating the Gtihub release...")

url = "https://api.github.com/repos/" + string(owner) + "/" + string(repo) + "/releases";

headers = [
    matlab.net.http.field.GenericField('Accept', 'application/vnd.github+json')
    matlab.net.http.field.GenericField('Authorization', "Bearer " + string(token))
    matlab.net.http.field.GenericField('X-GitHub-Api-Version', '2022-11-28')
];

data = struct( ...
    'tag_name', char(version), ...
    'target_commitish', 'master', ...
    'name', char(name), ...
    'body', char(description), ...
    'draft', false, ...
    'prerelease', false, ...
    'generate_release_notes', false ...
);
bodyObj = matlab.net.http.MessageBody();
bodyObj.Data = jsonencode(data);

req = matlab.net.http.RequestMessage('POST', headers', bodyObj);
uri = matlab.net.URI(url);

response = send(req, uri);

if response.StatusCode == matlab.net.http.StatusCode.OK || response.StatusCode == matlab.net.http.StatusCode.Created
    disp("Successfully created the GitHub release.");
else
    error("GitHub release creation failed: %s %s", string(response.StatusCode), jsonencode(response.Body.Data));
end

releaseID = response.Body.Data.id;
end