function varargout = CrazyflieToolboxVer
% CRAZYFLIETOOLBOXVER displays the Crazyflie Toolbox information.
%   CRAZYFLIETOOLBOXVER displays the information to the command prompt.
%
%   A = CRAZYFLIETOOLBOXVER returns in A the sorted struct array of version 
%   information for the Crazyflie Toolbox.
%     The definition of struct A is:
%             A.Name      : toolbox name
%             A.Version   : toolbox version number
%             A.Release   : toolbox release string
%             A.Date      : toolbox release date
%
%   M. Kutzer 27Jan2017, USNA

% Updates
%   

A.Name = 'Crazyflie Toolbox';
A.Version = '1.0.0';
A.Release = '(R2014a)';
A.Date = '27-Jan-2017';
A.URLVer = 1;

msg{1} = sprintf('MATLAB %s Version: %s %s',A.Name, A.Version, A.Release);
msg{2} = sprintf('Release Date: %s',A.Date);

n = 0;
for i = 1:numel(msg)
    n = max( [n,numel(msg{i})] );
end

fprintf('%s\n',repmat('-',1,n));
for i = 1:numel(msg)
    fprintf('%s\n',msg{i});
end
fprintf('%s\n',repmat('-',1,n));

if nargout == 1
    varargout{1} = A;
end