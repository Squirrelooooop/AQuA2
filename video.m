v = VideoWriter('datOrg1_movie.avi', 'Uncompressed AVI');
v.FrameRate = 30;
open(v);

for t = 1:size(datOrg1,4)
    frame = mat2gray(datOrg1(:,:,1,t));
    writeVideo(v, frame);
end

close(v);