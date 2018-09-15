% function numcars = cardetext(v)
v = vision.VideoFileReader('carfootage-short.mp4'); % read footage
detector = vision.ForegroundDetector('NumGaussians', 5, ...
    'NumTrainingFrames', 70); % creates foreground mask
blob = vision.BlobAnalysis('AreaOutputPort', false, ...
     'BoundingBoxOutputPort', true, 'CentroidOutputPort', true, ...
     'MinimumBlobArea', 3500); % analyzes connected regions in the mask
olddetects = []; 
carcandidates = struct('id',{},'bboxes',{},'framespresent',{},'framesgone',{});
% initialize matrix of tracks
numcars = 0; % initialize counter
se = strel('square', 3);
videoPlayer = vision.VideoPlayer();
while ~isDone(v)
    frame = v();
    foreground = detector(frame);
    foreground1 = bwareaopen(foreground, 500);
    foregroundfilt = imopen(foreground1, se);
    [CENTROID, BBOX] = step(blob, foregroundfilt);
    newdetects = BBOX;
    if isempty(olddetects) == 1
        olddetects = BBOX;
    end
    if isempty(carcandidates) == 1
        for m = 1:size(BBOX,1)
            carcandidates(m).bboxes = BBOX(m,:);
        end
    end
    overlapRatio = bboxOverlapRatio(olddetects, newdetects);
    % if any ratio > .5, take column # which indicates nowtracks
    detectcarcand = overlapRatio > 0.5;
    carcandindex = any(detectcarcand);
%     if sum(trackindex) > 0
    olddetects = [];
        for i = 1:sum(carcandindex)
            if carcandindex(i) == 1
                olddetects = [BBOX(i,:)];
                nolddetects = size(olddetects,1);
                ncarcandidates = numel(carcandidates);
                for j = 1:nolddetects
                    for k = 1:ncarcandidates
                    if bboxOverlapRatio(olddetects(j,:),carcandidates(k).bboxes(size(carcandidates(k).bboxes,1),:)) > 0.5
                        carcandidates(k).bboxes = [carcandidates(k).bboxes; olddetects(j,:)];
                    end
                    end
                end
            end
        end
%     end
    % put all detects into car candidates, if frame appearance greater than
    % 60, is a car, +1 num cars. delete candidates that appear less than 60
%     numcars = numcars + sum(lostdetects);
    shapeInserter = vision.ShapeInserter('BorderColor', 'White');
    out = shapeInserter(frame, BBOX);
    videoPlayer(out);
    % step function somewhere?
end
    for l = 1:numel(carcandidates)
        if size(carcandidates(l).bboxes,1) < 10
            carcanddiates(l) = [];
        end
    end
    numcars = numel(carcandidates);
% Will need to adjust inputs from Raspberry Pi Camera
% Need to perfect a cleaning method, false detections high, cleaning noise
% dependent on size which is not versatile
% Seriously need to debug tracking
