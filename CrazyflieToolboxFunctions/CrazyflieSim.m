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
    %   Figure       - figure containing simulation axes
    %   Axes         - axes containing simulation
    %
    % -Simulation Resolution and Complexity
    %   Resolution   - simulation resolution {['Coarse'], 'Fine'}
    %   Complexity   - simulation complexity {['Simple'], 'Complex'}
    %
    % -Crazyflie Model
    %   CFmodel      - string argument defining the model of the crazyflie
    %
    % -Crazyflie configuration paramters
    %   Pose         - 4x4 rigid body transform defining the body frame 
    %                  relative to the world frame
    %   PropAngles   - 1x4 array containing the angles for each prop
    %                  (angles defined in radians)
    %
    % -Frame Definitions
    %   Frame definitions will be introduced to define coordinate offsets
    %   for convenience. No frame definitions are defined at this time.
    %
    % -Frame Handles (hidden)
    %   hBody        - hgtransform object for the body-fixed crazyflie
    %                  frame
    %   hProp1       - hgtransform object for prop 1
    %   hProp2       - hgtransform object for prop 2
    %   hProp3       - hgtransform object for prop 3
    %   hProp4       - hgtransform object for prop 4
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
        end
        
    end
    
    
    % --------------------------------------------------------------------
    % General Use
    % --------------------------------------------------------------------
    methods(Access='public')
        
    end