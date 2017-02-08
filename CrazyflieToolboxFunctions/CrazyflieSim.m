classdef CrazyflieSim < matlab.mixin.SetGet % Handle
    % CrazyflieSim class for creating a designated crazyflie quadcopter
    % simulation/visualization
    %
    %   obj = CrazyflieSim(crazyflieModel) creates a simulation object for
    %   a specific model crazyflie (e.g. v1.0 or v2.0)
    %
    % CrazyflieSim Methods
    %   Initialize - Initialize the CrazyflieSim object.
    %   Zero       - Reset simulation to zero (move the simulation body
    %                frame and props to their initial configuration).
    %   Undo       - Return simulation to its previous configuration.
    %   get        - Query properties of the simulation object.
    %   set        - Update properties of the simulation object
    %   delete     - Delete the simulation object and all attributes.
    %
    % CrazyflieSim Properties
    % -Figure and Axes
    %   Figure      - figure containing simulation axes
    %   Axes        - axes containing simulation
    %
    % -Simulation Resolution and Complexity
    %   Resolution  - simulation resolution {['Coarse'], 'Fine'}
    %   Complexity  - simulation complexity {['Simple'], 'Complex'}
    %
    % -Crazyflie Model
    %   CFmodel     - string argument defining the model of the crazyflie
    %
    % -Crazyflie configuration paramters
    %   Position    - 3x1 array containing the body frame position (mm)
    %                 relative to the world frame
    %   Roll         - Scalar rotation (radians) about the body-fixed x-axis
    %   Pitch        - Scalar rotation (radians) about the body-fixed y-axis
    %   Yaw       - Scalar rotation (radians) about the body-fixed z-axis
    %   Pose        - 4x4 rigid body transform defining the body frame 
    %                  relative to the world frame
    %       NOTE: Pose is related to position, roll, pitch, and yaw using
    %               Pose = ...
    %                   Tx(Position(1))*Ty(Position(1))*Tz(Position(1))*...
    %                   Rz(Yaw)*Ry(Pitch)*Rx(Roll);
    %   PropAngles  - 1x4 array containing the angles for each prop
    %                  (angles defined in radians)
    %
    % -Frame Definitions
    %   Frame definitions will be introduced to define coordinate offsets
    %   for convenience. No frame definitions are defined at this time.
    %
    % -Frame Handles (hidden)
    %   hBody       - hgtransform object for the body-fixed crazyflie
    %                  frame
    %   hProp1      - hgtransform object for prop 1
    %   hProp2      - hgtransform object for prop 2
    %   hProp3      - hgtransform object for prop 3
    %   hProp4      - hgtransform object for prop 4
    %
    %   Crazyflie Nano (v1.0) frame and motor definitons
    %                               (forward)
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
    %                            (top/front side)
    %   
    %   Ref: https://wiki.bitcraze.io/projects:crazyflie:userguide:index
    %
    %   Crazyflie 2.0 frame and motor definitions
    %                               (forward)
    %                             +x-direction
    %                                   ^
    %                                   |
    %
    %                       [Motor_4]      [Motor_1]
    %                               \       /
    %                                RG | RG
    %           +y-dir <----         -------
    %                                B  |  B
    %                               /       \
    %                       [Motor_3]      [Motor_2]
    %
    %                            (top/front side)
    %   Ref: https://wiki.bitcraze.io/projects:crazyflie2:userguide:index
    %
    % See also
    %
    %   M. Kutzer, 27Jan2017, USNA
    
    % Updates
    %   
    
    % --------------------------------------------------------------------
    % General properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='public')
        Figure      % figure containing simulation axes
        Axes        % axes containing simulation
    end
    
    properties(GetAccess='public', SetAccess='private')
        Resolution  % simulation resolution {['Coarse'], 'Fine'}
        Complexity  % simulation complexity {['Simple'], 'Complex'}
    end
    
    properties(GetAccess='public', SetAccess='private')
        CFmodel     % string argument defining the model of the crazyflie
    end
    
    properties(GetAccess='public', SetAccess='public')
        Position    % 3x1 array containing the body frame position (mm)
                    % relative to the world frame
        Roll        % Scalar rotation (radians) about the body-fixed x-axis
        Pitch       % Scalar rotation (radians) about the body-fixed y-axis
        Yaw         % Scalar rotation (radians) about the body-fixed z-axis
        Pose        % 4x4 rigid body transform defining the body frame 
                    % relative to the world frame
        PropAngles  % 1x4 array containing the angles for each prop
                    % (angles defined in radians)
    end
    
    %-Frame Definitions
    %  Frame definitions will be introduced to define coordinate offsets
    %  for convenience. No frame definitions are defined at this time.
    
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        hBody       % hgtransform object for the body-fixed crazyflie
                    % frame
        hProp1      % hgtransform object for prop 1
        hProp2      % hgtransform object for prop 2
        hProp3      % hgtransform object for prop 3
        hProp4      % hgtransform object for prop 4
    end
    
    % --------------------------------------------------------------------
    % Internal properties
    % --------------------------------------------------------------------
    properties(GetAccess='public', SetAccess='private', Hidden=true)
        PriorConfig % previous configuration defined as a 2-element cell 
                    % array containing the prior pose (cell 1) and prop
                    % angles (cell 2)
    end
    
    % --------------------------------------------------------------------
    % Constructor/Destructor
    % --------------------------------------------------------------------
    methods(Access='public')
        function obj = CrazyflieSim
            % Create CrazyflieSim object
        end
        
        function delete(obj)
            % Object destructor
            if ishandle(obj.hBody)
                delete(obj.hBody);
            end
            
            if ishandle(obj.Axes)
                kids = get(obj.Axes,'Children');
                axsPrompt = false;
                if numel(kids) == 1
                    % Check if remaining object is a light
                    switch lower(kids(1).Type)
                        case 'light'
                            delete(obj.Axes);
                        otherwise
                            axsPrompt = true;
                    end
                else
                    axsPrompt = true;
                end
                
                if axsPrompt
                    % TODO - consider prompting user to delete axes
                end
            end
            
            if ishandle(obj.Figure)
                kids = get(obj.Figure,'Children');
                if numel(kids) > 0
                    % TODO - consider prompting user to delete figure
                else
                    delete(obj.Figure);
                end
            end
        end        
    end % end methods
    
    % --------------------------------------------------------------------
    % Initialization
    % --------------------------------------------------------------------
    methods(Access='public')
        function Initialize(obj,varargin)
            % Initialize initializes a CrazyFlie simulation
            %
            % Initialize(obj)
            % 
            % Initialize(obj, CFmodel)
            %
            % Initialize(obj, CFmodel, Complexity)
            %
            % Initialize(obj, CFmodel, Complexity, Resolution)
        end
        
    end % end methods
            
    % --------------------------------------------------------------------
    % General Use
    % --------------------------------------------------------------------
    methods(Access='public')
        function Zero(obj)
            % Reset simulation to zero (move the simulation body
            % frame and props to their initial configuration).
            obj.Pose = eye(4);
        end
        
        function Undo(obj)
            % Return simulation to its previous configuration.
            pConfig = obj.PriorConfig;
            if ~isempty(pConfig)
                pose_Old = pConfig{1};
                prop_Old = pConfig{2};
                if ~isempty(pose_Old) && ~isempty(prop_Old)
                    obj.Pose       = pose_Old{end};
                    obj.PropAngles = prop_Old{end};
                    pose_Old(end) = [];
                    prop_Old(end) = [];
                    obj.PriorConfig = {pose_Old, prop_Old};
                end
            end
        end
        
    end % end methods
    
    % --------------------------------------------------------------------
    % Getters/Setters
    % --------------------------------------------------------------------
    methods
        % GetAccess & SetAccess ------------------------------------------
        
        % Figure - figure handle containing simulation axes
        function fig = get.Figure(obj)
            fig = obj.Figure;
        end
        
        function obj = set.Figure(obj,fig)
            fig_old = obj.Figure;
            if ishandle(fig)
                switch lower(fig.Type)
                    case 'figure'
                        axs = obj.Axes;
                        set(axs,'Parent',fig);
                        obj.Figure = fig;
                        
                        if ~isempty(fig_old) && ishandle(fig_old)
                            close(fig_old);
                        end
                        return
                end
            end
            error('Specified figure handle must be valid.');
        end
        
        % Axes - axes handle containing simulation
        function axs = get.Axes(obj)
            axs = obj.Axes;
        end
        
        function obj = set.Axes(obj,axs)
            fig_old = obj.Figure;
            if ishandle(axs)
                switch lower(axs.Type)
                    case 'axes'
                        base = obj.hFrame0;
                        set(base,'Parent',axs);
                        daspect(axs,[1 1 1]);
                        addSingleLight(axs);
                        obj.Axes = axs;
                        fig = get(axs,'Parent');
                        obj.Figure = fig;
                        
                        if ~isempty(fig_old) && ishandle(fig_old)
                            close(fig_old);
                        end
                        return
                end
            end
            error('Specified figure handle must be valid.');
        end
        
        % Joints - 1x6 array containing joint values (radians)
        %function joints = get.Joints(obj)
        
        % Position - 3x1 array containing the body frame position (mm)
        %            relative to the world frame
        function position = get.Position(obj)
            pose = obj.Pose;
            position = pose(1:3,4);
        end
        
        function set.Position(obj,position)
            pose = obj.Pose;
            pose(1:3,4) = reshape( position, 3, [] );
            obj.Pose = pose;
            obj.Position = position;
        end
        
        % Roll - Scalar rotation (radians) about the body-fixed x-axis
        function roll = get.Roll(obj)
            pose  = obj.Pose;
            pitch = asin( -pose(3,1) );
            % yaw  = atan2( pose(2,1)/cos(pitch), pose(1,1)/cos(pitch) );
            roll  = atan2( pose(3,2)/cos(pitch), pose(3,3)/cos(pitch) );
        end
        
        function set.Roll(obj,roll)
            pitch = obj.Pitch;
            yaw   = obj.Yaw;
            X     = obj.Position;
            
            pose = Tx(X(1))*Ty(X(2))*Tz(X(3))*Rz(yaw)*Ry(pitch)*Rx(roll);
            
            obj.Pose = pose;
            obj.Roll = roll;
        end
        
        % Pitch - Scalar rotation (radians) about the body-fixed y-axis
        function pitch = get.Pitch(obj)
            pose  = obj.Pose;
            pitch = asin( -pose(3,1) );
            % yaw  = atan2( pose(2,1)/cos(pitch), pose(1,1)/cos(pitch) );
            % roll = atan2( pose(3,2)/cos(pitch), pose(3,3)/cos(pitch) );
        end
        
        function set.Pitch(obj,pitch)
            roll = obj.Roll;
            yaw  = obj.Yaw;
            X    = obj.Position;
            
            pose = Tx(X(1))*Ty(X(2))*Tz(X(3))*Rz(yaw)*Ry(pitch)*Rx(roll);
            
            obj.Pose  = pose;
            obj.Pitch = pitch;
        end
        
        % Yaw - Scalar rotation (radians) about the body-fixed z-axis
        function yaw = get.Yaw(obj)
            pose  = obj.Pose;
            pitch = asin( -pose(3,1) );
            yaw   = atan2( pose(2,1)/cos(pitch), pose(1,1)/cos(pitch) );
            % roll = atan2( pose(3,2)/cos(pitch), pose(3,3)/cos(pitch) );
        end
        
        function set.Yaw(obj,yaw)
            roll  = obj.Roll;
            pitch = obj.Pitch;
            X     = obj.Position;
            
            pose = Tx(X(1))*Ty(X(2))*Tz(X(3))*Rz(yaw)*Ry(pitch)*Rx(roll);
            
            obj.Pose = pose;
            obj.Yaw  = yaw;
        end
        
        % Pose - 4x4 rigid body transform defining the body frame
        %        relative to the world frame
        function pose = get.Pose(obj)
            pose = get(obj.hBody,'Matrix');
        end
        
        function set.Pose(obj,pose)
            % TODO - check for SE(3)
            set(obj.hBody,'Matrix',pose);
            obj.Pose = pose;
            
            propAngles  = obj.PropAngles;
            priorConfig = obj.PriorConfig;
            if ~isempty(priorConfig)
                priorConfig{1}{end+1} = pose;
                priorConfig{2}{end+1} = propAngles;
            else
                priorConfig{1} = {pose};
                priorConfig{2} = {propAngles};
            end
            obj.PriorConfig = priorConfig;
        end

        % PropAngles - 1x4 array containing the angles for each prop
        %              (angles defined in radians)
        function propAngles = get.PropAngles(obj)
            propAngles = obj.PropAngles;
        end
        
        function set.PropAngles(obj,propAngles)
            % hProp1 - hgtransform object for prop 1
            % hProp2 - hgtransform object for prop 2
            % hProp3 - hgtransform object for prop 3
            % hProp4 - hgtransform object for prop 4
            set(obj.hProp1,'Matrix',Rz(propAngles(1)));
            set(obj.hProp2,'Matrix',Rz(propAngles(2)));
            set(obj.hProp3,'Matrix',Rz(propAngles(3)));
            set(obj.hProp4,'Matrix',Rz(propAngles(4)));
            obj.PropAngles = propAngles;
            
            pose        = obj.Pose;
            priorConfig = obj.PriorConfig;
            if ~isempty(priorConfig)
                priorConfig{1}{end+1} = pose;
                priorConfig{2}{end+1} = propAngles;
            else
                priorConfig{1} = {pose};
                priorConfig{2} = {propAngles};
            end
            obj.PriorConfig = priorConfig;
        end
        
    end
end