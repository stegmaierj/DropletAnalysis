function closeRequestHandler(src,callbackdata)
%     % Construct a questdlg with three options
%     choice = questdlg('Would you like to save the project before closing?', ...
%         'Exit before saving?', ...
%         'Yes','No','Cancel','Cancel');
%     % Handle response
%     switch choice
%         case 'Yes'
%             saveProject;
%             delete(gcf);
%         case 'No'
%             delete(gcf);
%         case 'Cancel'
%             return;
%     end
    try
        saveProject;
    catch
        disp('Failed to save project ...');
    end
    
    delete(gcf);
    close all;
end