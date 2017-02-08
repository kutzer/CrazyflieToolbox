function cf_obj = createCrazyFlie1(varargin)
% CREATECRAZYFLIE creates a 3D visualization of a crazyflie 1.0
%   obj = CREATECRAZYFLIE This function creates a default 3D visualization 
%   of a crazyflie 1.0 quadcopter at the origin. This function returns a
%   structured array containing handles for the parent figure, axes, and
%   handles for body-fixed hgtransform objects for the body of the
%   crazyflie, and each prop.
%       obj.Figure - parent figure handle 
%       obj.Axes - parent axes handle
%       obj.Body - body-fixed hgtransform object connected to the body of
%           the crazyflie
%       obj.Motor - 1x4 array of body-fixed hgtransform objects connected
%           to each prop of the crazyflie
%       
%                             +x-direction
%                                   ^
%                                   |
%
%                                [Motor_1]
%                                   |
%                                 R | G
%           +y-dir <-- [Motor_4]---------[Motor_2]
%                                   | B
%                                   |
%                                [Motor_3]
%
%                              (front side)
%       
%   Ref: https://wiki.bitcraze.io/projects:crazyflie:userguide:index
%
%   CREATECRAZYFLIE(___,Name,Value) specifies properties using one or more 
%   Name,Value pair arguments.
%       'complexity'    - [ {'Simple'}, 'Complex' ]
%       'matrix'        - 4x4 homogenious transform
%       'parent'        - Axes or other hgtransform handle
%       'propAlignment' - 1x4 array containing prop orientations in radians
%       'resolution'    - [ {'Coarse'}, 'Fine' ]
%       'tag'           - String describing object
%
%   CREATECRAZYFLIE(axes_handle,___) plots into the axes specified by 
%   axes_handle instead of into the current axes (gca). The option, 
%   axes_handle can precede any of the input combinations in the previous 
%   syntaxes.
%
%   Example
%       % Create crazyflie visualization
%       cf_obj = createCrazyFlie('Complexity','Complex',...
%           'Resolution','Coarse','PropAlignment',[0,pi/6,pi/5,pi/4]);
%       % Get current body position and orientation
%       H = get(cf_obj.Body,'Matrix');
%       % Plot current position
%       plt = plot3(H(1,4),H(2,4),H(3,4),'.m');
%       % Set "prop speed" and body movement 
%       delta_prop = [pi/7,pi/8,pi/9,pi/10];
%       delta_body = makehgtform('translate',[0.1,0.1,0.3],...
%           'zrotate',pi/100,'xrotate',pi/200);
%       % Animate
%       while ishandle(cf_obj.Figure)
%           % Update prop orientations
%           for i = 1:numel(cf_obj.Motor)
%               G = get(cf_obj.Motor(i),'Matrix');
%               set(cf_obj.Motor(i),'Matrix',G*makehgtform('zrotate',delta_prop(i)));
%           end
%           % Update body position and orientation
%           H = get(cf_obj.Body,'Matrix');
%           set(cf_obj.Body,'Matrix',H*delta_body);
%           % Update position trajectory plot
%           xData = get(plt,'xdata');
%           yData = get(plt,'ydata');
%           zData = get(plt,'zdata');
%           set(plt,'xdata',[xData,H(1,4)],'ydata',[yData,H(2,4)],'zdata',[zData,H(3,4)]);
%           drawnow
%       end
%
%   See also Triad hgtransform stlpatch
%
%   (c) M. Kutzer 20Dec2014, USNA

%Updates
%   30June2015 - Updated input arguments and documentation
%   06July2015 - Updated documentation and added example

%TODO - check for stlpatch and point to website:
% N/A

%TODO - check for addsinglelight and point to website:
% http://www.mathworks.com/matlabcentral/fileexchange/48617-add-single-light-object

%TODO - check for triad and point to website:
% http://www.mathworks.com/matlabcentral/fileexchange/48810-visualize-reference-frame

%% set defaults
resolution = 'Coarse';
complexity = 'Simple';
prop_alignment = [0,0,0,0];
H0 = eye(4);
tag = 'CrazyFlie';
mom = [];

%% parse inputs
if nargin > 0
    if ishandle(varargin{1})
        mom = varargin{1};
        varargin(1) = [];
    end
    
    n = numel(varargin);
    for i = 1:2:n
        if i >= n
            error( sprintf('No argument provided for "%s"',varargin{i}) );
        end
        switch lower(varargin{i})
            case 'complexity'
                complexity = varargin{i+1};
                complexity = sprintf('%s%s',upper(complexity(1)),lower(complexity(2:end)));
            case 'matrix'
                H0 = varargin{i+1};
            case 'parent'
                mom = varargin{i+1};
            case 'propalignment'
                prop_alignment = varargin{i+1};
            case 'resolution'
                resolution = varargin{i+1};
                resolution = sprintf('%s%s',upper(resolution(1)),lower(resolution(2:end)));
            case 'tag'
                tag = varargin{i+1};
            otherwise
                error( sprintf('Unexpected property "%s"',varargin{i}) );
        end
    end
end

%% setup figure
if isempty(mom)
    % Default figure
    fig = figure('Name','CrazyFlie','Position',[100,200,960,540]);
    axs = axes('Parent',fig);
    mom = axs;
    xlabel('x')
    ylabel('y')
    zlabel('z')
    daspect([1 1 1]);
    view(3);
    hold on
else
    % Existing figure with defined parent
    axs = mom;
    while ~strcmp('axes', get(axs,'type'))
        axs = get(axs,'parent');
    end
    fig = get(axs,'Parent');
    while ~strcmp('figure', get(fig,'type'))
        fig = get(fig,'parent');
    end
end

h = triad('Parent',mom,'LineWidth',3,'Scale',35,'Matrix',H0,'visible','off');
if ~isempty(tag)
    set(h,'tag',tag);
end

%% load body stl file(s)
pathname = 'STL Files, CrazyFlie';
switch complexity
    case 'Simple'
        body_stl = sprintf('CrazyFlie_%s.fig',resolution);
        
        %[cf,stltitle] = stlpatch( fullfile(pathname,body_stl) );
        %body = patch(cf);
        open( fullfile(folderName,body_stl) );
        fig = gcf;
        set(fig,'Visible','off');
        axs = get(fig,'Children');
        body = get(axs,'Children');
                        
        set(body,'Parent',h,'FaceColor',[0.7,0.7,0.7],'Tag','Body');
        close(fig)
    case 'Complex'
        components = {...
            'CF_ContactStrip-1';...
            'CF_Bracketed_Motor-4 CF_Motor-1';...
            'CF_Bracketed_Motor-4 CF_Bracket-1';...
            'CF_Bracketed_Motor-3 CF_Motor-1';...
            'CF_Bracketed_Motor-3 CF_Bracket-1';...
            'CF_Bracketed_Motor-2 CF_Motor-1';...
            'CF_Bracketed_Motor-2 CF_Bracket-1';...
            'CF_Bracketed_Motor-1 CF_Motor-1';...
            'CF_Bracketed_Motor-1 CF_Bracket-1';...
            'CF_Board-1';...
            'CF_Battery-1'};
        
        color_motor   = [0.60, 0.60, 0.60];
        color_bracket = [0.95, 0.95, 0.95];
        color_strip   = [0.90, 0.90, 0.90];
        color_board   = [0.10, 0.10, 0.10];
        color_battery = [0.60, 0.80, 0.80];
        
        component_color = [...
            color_strip;...     % contact strip
            color_motor;...     % motor 
            color_bracket;...   % motor bracket
            color_motor;...     % motor 
            color_bracket;...   % motor bracket
            color_motor;...     % motor 
            color_bracket;...   % motor bracket
            color_motor;...     % motor 
            color_bracket;...   % motor bracket
            color_board;...     % board
            color_battery];     % battery
        
        alpha_motor   = 1.00;
        alpha_bracket = 0.35;
        alpha_strip   = 1.00;
        alpha_board   = 1.00;
        alpha_battery = 1.00;
        
        component_alpha = [...
            alpha_strip;...     % contact strip
            alpha_motor;...     % motor 
            alpha_bracket;...   % motor bracket
            alpha_motor;...     % motor 
            alpha_bracket;...   % motor bracket
            alpha_motor;...     % motor 
            alpha_bracket;...   % motor bracket
            alpha_motor;...     % motor 
            alpha_bracket;...   % motor bracket
            alpha_board;...     % board
            alpha_battery];     % battery
        
        for i = 1:numel(components)
            filename = sprintf('CrazyFlie_%s - %s.fig',resolution,components{i});
            %[cf,stltitle] = stlpatch( fullfile(pathname,filename) );
            %cmpnt = patch(cf);
            open( fullfile(folderName,body_stl) );
            fig = gcf;
            set(fig,'Visible','off');
            axs = get(fig,'Children');
            cmpnt = get(axs,'Children');
        
            set(cmpnt,'Parent',h,'FaceColor',component_color(i,:),...
                'FaceAlpha',component_alpha(i,:),'Tag',components{i});
            
            close(fig);
        end
    otherwise
        error('Unexpected value for "complexity" parameter.');
end

%% load prop stl files
cw_stl = sprintf('CF_CW_Propeller_%s.fig',resolution);
ccw_stl = sprintf('CF_CCW_Propeller_%s.fig',resolution);

%[cw,stltitle] = stlpatch( fullfile(pathname,cw_stl) );
%[ccw,stltitle] = stlpatch( fullfile(pathname,ccw_stl) );

%m(1) = patch(ccw);
%m(2) = patch(cw);
%m(3) = patch(ccw);
%m(4) = patch(cw);

offset = ...
    [ 43.00,  0.00,  7.90;...
       0.00,-43.00,  7.90;...
     -43.00,  0.00,  7.90;...
       0.00, 43.00,  7.90];

for i = 1:numel(m)
    g(i) = hgtransform('Parent',h,'Matrix',...
        makehgtform('translate',offset(i,:),'zrotate',prop_alignment(i)));
    f(i) = hgtransform('Parent',g(i));
    set(m(i),'Parent',f(i));
    
    set(g(i),'Tag',sprintf('M%d Prop Base',i));
    set(f(i),'Tag',sprintf('M%d Prop',i));
end

%% add light
lgt = addSingleLight(axs);

%% package output
cf_obj.Figure = fig;
cf_obj.Axes = axs;
cf_obj.Body = h;
for i = 1:numel(f)
    cf_obj.Motor(i) = f(i);
end
