function saveGIF(filename,images)
%SAVEGIF Given a filename and a set of images save a gif.
% The last image is the first one in the image sequence.
%
% Usage example:
% 
% >> saveGIF('animatedDotRaster3D.gif', im);
%
% $Author: DRTorresRuiz$
    for i = length(images):-1:1
        
        [A,map] = rgb2ind(images{i},256);
        if i == length(images)
        
            imwrite(A, map, filename,'gif','LoopCount',inf,'DelayTime',1 );
        else
            
            imwrite(A, map, filename,'gif','WriteMode','append','DelayTime',1);
        end
    end
end

