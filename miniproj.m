% function numcars = cardetext(v)
v = vision.VideoFileReader('carfootage-short.mov'); % read footage
detector = vision.ForegroundDetector('NumGaussians', 3, ...
    'NumTrainingFrames', 150); % creates foreground mask
blob = vision.BlobAnalysis('AreaOutputPort', false, ...
     'BoundingBoxOutputPort', true, 'CentroidOutputPort', false, ...
     'MinimumBlobArea', 3500); % analyzes connected regions in the mask
pasttracks = []; % initialize matrix of tracks
numcars = 0; % initialize counter
videoPlayer = vision.VideoPlayer();
while ~isDone(v)
    frame = v();
    foreground = detector(frame);
    foregroundfilt = bwareaopen(foreground, 500); % removes noise based
    % on size
    [BBOX] = step(blob, foregroundfilt);
    nowtracks = BBOX;
    if isempty(pasttracks) == 1
        pasttracks = BBOX;
    end
    overlapRatio = bboxOverlapRatio(pasttracks, nowtracks);
    % if any ratio > .9, take column # which indicates nowtracks
    detecttrack = overlapRatio > 0.9;
    trackindex = any(detecttrack);
%     if sum(trackindex) > 0
        pasttracks = [];
        for i = 1:sum(trackindex)
            if trackindex(i) == 1
                pasttracks = [BBOX(i, :)] ;
            end
        end
%     end
    losttracks = any(trackindex == 0);
    numcars = numcars + sum(losttracks);
    shapeInserter = vision.ShapeInserter('BorderColor', 'White');
    out = shapeInserter(frame, BBOX);
    videoPlayer(out);
    % step function somewhere?
end
% Will need to adjust inputs from Raspberry Pi Camera
% Need to perfect a cleaning method, false detections high, cleaning noise
% dependent on size which is not versatile
% Seriously need to debug tracking
