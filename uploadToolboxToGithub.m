function uploadToolboxToGithub(owner, repo, releaseID, path_to_toolbox, token)
%uploadToolboxToGithub Uploads a .mltbx file as a GitHub release asset.
%   Inputs:
%       owner           - GitHub username (char or string)
%       repo            - GitHub repository name (char or string)
%       releaseID       - The releaseID you got from creating the release
%       path_to_toolbox - Path to .mltbx file to upload
%       token           - GitHub personal access token (char or string)

p = inputParser;
addRequired(p, 'owner', @(x) ischar(x) || isstring(x));
addRequired(p, 'repo', @(x) ischar(x) || isstring(x));
addRequired(p, 'releaseID', @(x) isnumeric(x));
addRequired(p, 'path_to_toolbox', @(x) (ischar(x) || isstring(x)) && isfile(x));
addRequired(p, 'token', @(x) ischar(x) || isstring(x));

parse(p, owner, repo, releaseID, path_to_toolbox, token);

%% Upload the toolbox file
% Reference see % https://docs.github.com/en/rest/releases/assets?apiVersion=2022-11-28#upload-a-release-asset

disp("Uploading toolbox file...")

[~, filename, ext] = fileparts(string(path_to_toolbox));
url = "https://uploads.github.com/repos/" + string(owner) + "/" + string(repo) + "/releases/" + string(releaseID) +  "/assets?name=" + filename + ext;

headers = [
    matlab.net.http.field.GenericField('Accept', 'application/vnd.github+json')
    matlab.net.http.field.GenericField('Authorization', "Bearer " + token)
    matlab.net.http.field.GenericField('X-GitHub-Api-Version', '2022-11-28')
    matlab.net.http.field.ContentTypeField('application/octet-stream')
];

fid = fopen(string(path_to_toolbox), 'rb');
toolboxFileData = fread(fid, Inf, '*uint8');
fclose(fid);

bodyObj = matlab.net.http.MessageBody();
bodyObj.Data = toolboxFileData;

req = matlab.net.http.RequestMessage('POST', headers', bodyObj);
uri = matlab.net.URI(url);

response = send(req, uri);

if response.StatusCode == matlab.net.http.StatusCode.OK || response.StatusCode == matlab.net.http.StatusCode.Created
    disp("Successfully uploaded the toolbox file to the GitHub release.");
else
    error("GitHub toolbox file upload failed: %s %s", string(response.StatusCode), jsonencode(response.Body.Data));
end
end