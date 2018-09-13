% function numcars = cardetext(v)
v = vision.VideoFileReader('carfootage.mp4'); % read footage
detector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 100); % creates foreground mask
blob = vision.BlobAnalysis('AreaOutputPort', false, ...
     'BoundingBoxOutputPort', true, 'CentroidOutputPort', true, ...
     'MinimumBlobArea', 70); % analyzes connected regions in the mask
numcars = 0; % initialize counter
videoPlayer = vision.VideoPlayer();
while ~isDone(v)
    frame = v();
    foreground = detector(frame);
%     bbox = blob(foreground);
    [CENTROID, BBOX] = step(blob, foreground);
    shapeInserter = vision.ShapeInserter('BorderColor', 'White');
    out = shapeInserter(frame, BBOX);
    videoPlayer(out);
    % step function somewhere?
end
% Will need to adjust inputs from Raspberry Pi Camera
% A lot of this code is just taken from the Matlab site so we're gonna
% have to shake it up a bit to make it our own thing
% NEED TO CLEAN NOISE FROM DETECTION!
% Car counter, will utilize the centroid output from blob analysis since
% that counts blob. Tracking blob's from creation to disappearance will
% +1 counter
