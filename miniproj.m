% function numcars = cardetext(v)
v = vision.VideoFileReader('carfootage.mp4'); % read footage
detector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 100); % creates foreground mask
blob = vision.BlobAnalysis('AreaOutputPort', false, ...
     'BoundingBoxOutputPort', true, 'CentroidOutputPort', false, ...
     'MinimumBlobArea', 70); % analyzes connected regions in the mask
numcars = 0; % initialize counter
while ~isDone(v)
    frame = v();
    foreground = detector(frame);
    bbox = blob(foreground);
    % step function somewhere?
end % process video
% Detecting code, NEED TO CLEAN NOISE!
% Car counter
