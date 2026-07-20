%                                   Pilot Plant OPC Control Template
%                                                  Nicholas O'Keeffe
%                                              ICE, ICSE Thesis 2022
clear, close all, hold off
% 
%    '||'''|, '||''''|      /.\      '||'''|.    '||\   /||` '||''''| 
%     ||   ||  ||   .      // \\      ||   ||     ||\\.//||   ||   .  
%     ||...|'  ||'''|     //...\\     ||   ||     ||     ||   ||'''|  
%     || \\    ||        //     \\    ||   ||     ||     ||   ||      
%    .||  \\. .||....| .//       \\. .||...|'    .||     ||. .||....| 
%
%   Before using this program, it is strongly recommended that the
%   Associated document 'PP-5007: 'OPCControlTemplateR0’: Use and Function'
%   is read. This document gives both a quick start guide to this program
%   and a more extensive explanation of its function
%       Some tips:
%       - Navigate the program using the Go To menu on the editor ribbon of
%           the MATLAB toolbar
%       - Once the program is known to be configured:
%           > Start the program using the run button.
%           > The program runs as an infinite loop so stop the program
%               using the stop button or ctrl+c
%       - Export data using either the trendline feature of the EPKS HMI 
%           OR, using the save() function from the MATLAB command line once
%           the program has been stopped.
                                                                 
%% Contents
% Sections:
%       I. Initialization
%           1: Server Connect, Loop Time Set
%           2a: Control Group Establishment 
%           2b: Bonus Variable Group Establishment
%           3a: Variable Creation, Initialization and Server Linking
%           3b: Bonus Variables Creation and First Read
%       II. Main Loop (Controllers)
%           3c: Bonus Variables Read
%           4: Controller 1, [FP-141 (BMT input pump)]
%           5: Controller 2, [BM-201 (Ball Mill Speed)] 
%                   \___>    *Out of Commission (OOC)*
%           6: Controller 3, [BMP-241 (BMT output pump)]
%           7: Controller 4, [CRP-341 (Cyclone Recycle Pump)]
%           8: Controller 5, [CUFP-361 (Cyclone Underflow Pump)]
%           9: Controller 6, [LUFP-421 (Lamella Underflow Pump)]
%           10: Controller 7, [FDP-521 (Feed Disturbance Pump)]
%           11: Controller 8, [FCV-541 (NLT input)]
%           12: Controller 9, [NTP-561 (Needle Tank Underflow Pump)]
%           13: Controller 10, [FCV-570 (CSTR1 input)]
%           14: Controller 11, [FCV-574 (NT to BMT)]----------------*OOC*
%           15: Controller 12, [FCV-622 (CSTR1 Steam In)]-----------*OOC*
%           16: Controller 13, [FCV-642 (CSTR2 Steam In)]
%           17: Controller 14, [FCV-662 (CSTR3 Steam In)]
%           18: Controller 15, [FCV-688 (System Output)]
%           19: Controller 16, [FCV-690 (CSTR3 Reflux)]
%           20: Controller 17, [PP-681 (Product Pump)]
%           21: Controller 18, [SPARE]
%           22: Controller 19, [FCV-571 (NT to ST Bank)]------------*OOC*
%           23: Controller 20, [SPARE]

%%       I. Initialization
%%           1: Server Connect, Loop Time Set
server = opcda('ppserver1', 'HWHsc.OPCServer');
connect(server);

dt = 1;         % <---- Loop Time Set (Default = 1 second)

%%           2a: Control Group Establishment 
%              (Groups Synonymous With Control Modules 
%              in EPKS)
cont1.grp = addgroup(server, 'FP_REF_141-R1A');     % Controller 1 CM
    % Controller 2 group unestablished [BM OOC]
cont3.grp = addgroup(server, 'BMP_REF_241-R1A');    % Controller 3 CM 
cont4.grp = addgroup(server, 'CRP_REF_341-R1A');    % Controller 4 CM
cont5.grp = addgroup(server, 'CUFP_REF_361-R1A');   % Controller 5 CM
    % Controller 6 group unestablished
cont7.grp = addgroup(server, 'FDP_REF_521-R1A');    % Controller 7 CM
cont8.grp = addgroup(server, 'FCV_541-R1A');        % Controller 8 CM
cont9.grp = addgroup(server, 'NTP_REF_561-R1A');    % Controller 9 CM
cont10.grp = addgroup(server, 'FCV_570-R1A');       % Controller 10 CM
    % Controller 11 group unestablished [FCV-574 OOC]
    % Controller 12 group unestablished [FCV-622 OOC]
cont13.grp = addgroup(server, 'FCV_642-R1A');       % Controller 13 CM
cont14.grp = addgroup(server, 'FCV_662-R1A');       % Controller 14 CM
cont15.grp = addgroup(server, 'FCV_688-R1A');       % Controller 15 CM
cont16.grp = addgroup(server, 'FCV_690-R1A');       % Controller 16 CM
cont17.grp = addgroup(server, 'PP_REF_681-R1A');    % Controller 17 CM
    % (18) SPARE CONTROLLER
    % Controller 19 group unestablished [FCV-571 OOC]
    % (20) SPARE CONTROLLER

%%           2b: Bonus Variable Group Establishment
%              Use this field to add additional point parameter groups for
%              use in designed controllers, e.g.,
%               Bonus.ft148grp = addgroup(server, 'FT_148'); 
%                   \__> Flow Transmitter 148 Control Module

%%           3a: Variable Creation and Server Linking
% Initialization of n and t
n = 1;
t(n) = 0*dt;

tic % start timer

% Controller 1 Variable Creation
% Reads
cont1.fp141_read = additem(cont1.grp, 'FP_REF_141-R1A.FP_141.PV', 'double');
cont1.pv1_read = additem(cont1.grp, 'FP_REF_141-R1A.PV1.PV', 'double');
cont1.pv2_read = additem(cont1.grp, 'FP_REF_141-R1A.PV2.PV', 'double');
cont1.dv_read = additem(cont1.grp, 'FP_REF_141-R1A.DV.PV', 'double');
cont1.sp_read = additem(cont1.grp, 'FP_REF_141-R1A.SP.PV', 'double');
cont1.OpcVarA_read = additem(cont1.grp, 'FP_REF_141-R1A.OPC_VarA.PV', 'double');
cont1.OpcVarB_read = additem(cont1.grp, 'FP_REF_141-R1A.OPC_VarB.PV', 'double');
cont1.OpcVarC_read = additem(cont1.grp, 'FP_REF_141-R1A.OPC_VarC.PV', 'double');
cont1.OpcVarD_read = additem(cont1.grp, 'FP_REF_141-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont1.opcEnable = additem(cont1.grp, 'FP_REF_141-R1A.OPCenable.PVFL', 'double');

% Writes
cont1.fp141_write = additem(cont1.grp, 'FP_REF_141-R1A.FP141_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont1.fp141_read));
tempreadPv1 = struct2cell(read(cont1.pv1_read));
tempreadPv2 = struct2cell(read(cont1.pv2_read));
tempreadDv = struct2cell(read(cont1.dv_read));
tempreadSp = struct2cell(read(cont1.sp_read));
tempOpcState = struct2cell(read(cont1.opcEnable));
tempOpcVarA = struct2cell(read(cont1.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont1.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont1.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont1.OpcVarD_read));

cont1.fp141(n) = cell2mat(tempreadMvOut(2));
cont1.pv1(n) = cell2mat(tempreadPv1(2));
cont1.pv2(n) = cell2mat(tempreadPv2(2));
cont1.dv(n) = cell2mat(tempreadDv(2));
cont1.sp(n) = cell2mat(tempreadSp(2));
cont1.OPC(n) = cell2mat(tempOpcState(2));
cont1.OpcVarA = cell2mat(tempOpcVarA(2));
cont1.OpcVarB = cell2mat(tempOpcVarB(2));
cont1.OpcVarC = cell2mat(tempOpcVarC(2));
cont1.OpcVarD = cell2mat(tempOpcVarD(2));
cont1.mvDes(n) = 0;
cont1.err(n) = 0;
cont1.OPCprev = cont1.OPC(1);

% Controller 2 Variable Creation
    % Controller 2 group unestablished [BM OOC]

% Controller 3 Variable Creation
% Reads
cont3.bmp241_read = additem(cont3.grp, 'BMP_REF_241-R1A.BMP_241.PV', 'double');
cont3.pv1_read = additem(cont3.grp, 'BMP_REF_241-R1A.PV1.PV', 'double');
cont3.pv2_read = additem(cont3.grp, 'BMP_REF_241-R1A.PV2.PV', 'double');
cont3.dv_read = additem(cont3.grp, 'BMP_REF_241-R1A.DV.PV', 'double');
cont3.sp_read = additem(cont3.grp, 'BMP_REF_241-R1A.SP.PV', 'double');
cont3.OpcVarA_read = additem(cont3.grp, 'BMP_REF_241-R1A.OPC_VarA.PV', 'double');
cont3.OpcVarB_read = additem(cont3.grp, 'BMP_REF_241-R1A.OPC_VarB.PV', 'double');
cont3.OpcVarC_read = additem(cont3.grp, 'BMP_REF_241-R1A.OPC_VarC.PV', 'double');
cont3.OpcVarD_read = additem(cont3.grp, 'BMP_REF_241-R1A.OPC_VarD.PV', 'double');


% Read/Write
cont3.opcEnable = additem(cont3.grp, 'BMP_REF_241-R1A.OPCenable.PVFL', 'double');

% Writes
cont3.bmp241_write = additem(cont3.grp, 'BMP_REF_241-R1A.BMP241_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont3.bmp241_read));
tempreadPv1 = struct2cell(read(cont3.pv1_read));
tempreadPv2 = struct2cell(read(cont3.pv2_read));
tempreadDv = struct2cell(read(cont3.dv_read));
tempreadSp = struct2cell(read(cont3.sp_read));
tempOpcState = struct2cell(read(cont3.opcEnable));
tempOpcVarA = struct2cell(read(cont3.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont3.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont3.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont3.OpcVarD_read));

cont3.fp141(n) = cell2mat(tempreadMvOut(2));
cont3.pv1(n) = cell2mat(tempreadPv1(2));
cont3.pv2(n) = cell2mat(tempreadPv2(2));
cont3.dv(n) = cell2mat(tempreadDv(2));
cont3.sp(n) = cell2mat(tempreadSp(2));
cont3.OPC(n) = cell2mat(tempOpcState(2));
cont3.OpcVarA = cell2mat(tempOpcVarA(2));
cont3.OpcVarB = cell2mat(tempOpcVarB(2));
cont3.OpcVarC = cell2mat(tempOpcVarC(2));
cont3.OpcVarD = cell2mat(tempOpcVarD(2));
cont3.mvDes(n) = 0;
cont3.err(n) = 0;
cont3.OPCprev = cont3.OPC(1);

% Controller 4 Variable Creation
% Reads
cont4.crp341_read = additem(cont4.grp, 'CRP_REF_341-R1A.CRP_341.PV', 'double');
cont4.pv1_read = additem(cont4.grp, 'CRP_REF_341-R1A.PV1.PV', 'double');
cont4.pv2_read = additem(cont4.grp, 'CRP_REF_341-R1A.PV2.PV', 'double');
cont4.dv_read = additem(cont4.grp, 'CRP_REF_341-R1A.DV.PV', 'double');
cont4.sp_read = additem(cont4.grp, 'CRP_REF_341-R1A.SP.PV', 'double');
cont4.OpcVarA_read = additem(cont4.grp, 'CRP_REF_341-R1A.OPC_VarA.PV', 'double');
cont4.OpcVarB_read = additem(cont4.grp, 'CRP_REF_341-R1A.OPC_VarB.PV', 'double');
cont4.OpcVarC_read = additem(cont4.grp, 'CRP_REF_341-R1A.OPC_VarC.PV', 'double');
cont4.OpcVarD_read = additem(cont4.grp, 'CRP_REF_341-R1A.OPC_VarD.PV', 'double');


% Read/Write
cont4.opcEnable = additem(cont4.grp, 'CRP_REF_341-R1A.OPCenable.PVFL', 'double');

% Writes
cont4.crp341_write = additem(cont4.grp, 'CRP_REF_341-R1A.CRP341_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont4.crp341_read));
tempreadPv1 = struct2cell(read(cont4.pv1_read));
tempreadPv2 = struct2cell(read(cont4.pv2_read));
tempreadDv = struct2cell(read(cont4.dv_read));
tempreadSp = struct2cell(read(cont4.sp_read));
tempOpcState = struct2cell(read(cont4.opcEnable));
tempOpcVarA = struct2cell(read(cont4.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont4.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont4.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont4.OpcVarD_read));

cont4.crp341(n) = cell2mat(tempreadMvOut(2));
cont4.pv1(n) = cell2mat(tempreadPv1(2));
cont4.pv2(n) = cell2mat(tempreadPv2(2));
cont4.dv(n) = cell2mat(tempreadDv(2));
cont4.sp(n) = cell2mat(tempreadSp(2));
cont4.OPC(n) = cell2mat(tempOpcState(2));
cont4.OpcVarA = cell2mat(tempOpcVarA(2));
cont4.OpcVarB = cell2mat(tempOpcVarB(2));
cont4.OpcVarC = cell2mat(tempOpcVarC(2));
cont4.OpcVarD = cell2mat(tempOpcVarD(2));
cont4.mvDes(n) = 0;
cont4.err(n) = 0;
cont4.OPCprev = cont4.OPC(1);

% Controller 5 Variable Creation
% Reads
cont5.cufp361_read = additem(cont5.grp, 'CUFP_REF_361-R1A.CUFP_361.PV', 'double');
cont5.pv1_read = additem(cont5.grp, 'CUFP_REF_361-R1A.PV1.PV', 'double');
cont5.pv2_read = additem(cont5.grp, 'CUFP_REF_361-R1A.PV2.PV', 'double');
cont5.dv_read = additem(cont5.grp, 'CUFP_REF_361-R1A.DV.PV', 'double');
cont5.sp_read = additem(cont5.grp, 'CUFP_REF_361-R1A.SP.PV', 'double');
cont5.OpcVarA_read = additem(cont5.grp, 'CUFP_REF_361-R1A.OPC_VarA.PV', 'double');
cont5.OpcVarB_read = additem(cont5.grp, 'CUFP_REF_361-R1A.OPC_VarB.PV', 'double');
cont5.OpcVarC_read = additem(cont5.grp, 'CUFP_REF_361-R1A.OPC_VarC.PV', 'double');
cont5.OpcVarD_read = additem(cont5.grp, 'CUFP_REF_361-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont5.opcEnable = additem(cont5.grp, 'CUFP_REF_361-R1A.OPCenable.PVFL', 'double');

% Writes
cont5.cufp361_write = additem(cont5.grp, 'CUFP_REF_361-R1A.CUFP361_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont5.cufp361_read));
tempreadPv1 = struct2cell(read(cont5.pv1_read));
tempreadPv2 = struct2cell(read(cont5.pv2_read));
tempreadDv = struct2cell(read(cont5.dv_read));
tempreadSp = struct2cell(read(cont5.sp_read));
tempOpcState = struct2cell(read(cont5.opcEnable));
tempOpcVarA = struct2cell(read(cont5.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont5.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont5.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont5.OpcVarD_read));

cont5.cufp361(n) = cell2mat(tempreadMvOut(2));
cont5.pv1(n) = cell2mat(tempreadPv1(2));
cont5.pv2(n) = cell2mat(tempreadPv2(2));
cont5.dv(n) = cell2mat(tempreadDv(2));
cont5.sp(n) = cell2mat(tempreadSp(2));
cont5.OPC(n) = cell2mat(tempOpcState(2));
cont5.OpcVarA = cell2mat(tempOpcVarA(2));
cont5.OpcVarB = cell2mat(tempOpcVarB(2));
cont5.OpcVarC = cell2mat(tempOpcVarC(2));
cont5.OpcVarD = cell2mat(tempOpcVarD(2));
cont5.mvDes(n) = 0;
cont5.err(n) = 0;
cont5.OPCprev = cont5.OPC(1);

% Controller 6 Variable Creation
    % Controller 6 group unestablished -- LUP unused

% Controller 7 Variable Creation
% Reads
cont7.fdp521_read = additem(cont7.grp, 'FDP_REF_521-R1A.FDP_521.PV', 'double');
cont7.pv1_read = additem(cont7.grp, 'FDP_REF_521-R1A.PV1.PV', 'double');
cont7.pv2_read = additem(cont7.grp, 'FDP_REF_521-R1A.PV2.PV', 'double');
cont7.dv_read = additem(cont7.grp, 'FDP_REF_521-R1A.DV.PV', 'double');
cont7.sp_read = additem(cont7.grp, 'FDP_REF_521-R1A.SP.PV', 'double');
cont7.OpcVarA_read = additem(cont7.grp, 'FDP_REF_521-R1A.OPC_VarA.PV', 'double');
cont7.OpcVarB_read = additem(cont7.grp, 'FDP_REF_521-R1A.OPC_VarB.PV', 'double');
cont7.OpcVarC_read = additem(cont7.grp, 'FDP_REF_521-R1A.OPC_VarC.PV', 'double');
cont7.OpcVarD_read = additem(cont7.grp, 'FDP_REF_521-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont7.opcEnable = additem(cont7.grp, 'FDP_REF_521-R1A.OPCenable.PVFL', 'double');

% Writes
cont7.fdp521_write = additem(cont7.grp, 'FDP_REF_521-R1A.FDP521_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont7.fdp521_read));
tempreadPv1 = struct2cell(read(cont7.pv1_read));
tempreadPv2 = struct2cell(read(cont7.pv2_read));
tempreadDv = struct2cell(read(cont7.dv_read));
tempreadSp = struct2cell(read(cont7.sp_read));
tempOpcState = struct2cell(read(cont7.opcEnable));
tempOpcVarA = struct2cell(read(cont7.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont7.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont7.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont7.OpcVarD_read));

cont7.fdp521(n) = cell2mat(tempreadMvOut(2));
cont7.pv1(n) = cell2mat(tempreadPv1(2));
cont7.pv2(n) = cell2mat(tempreadPv2(2));
cont7.dv(n) = cell2mat(tempreadDv(2));
cont7.sp(n) = cell2mat(tempreadSp(2));
cont7.OPC(n) = cell2mat(tempOpcState(2));
cont7.OpcVarA = cell2mat(tempOpcVarA(2));
cont7.OpcVarB = cell2mat(tempOpcVarB(2));
cont7.OpcVarC = cell2mat(tempOpcVarC(2));
cont7.OpcVarD = cell2mat(tempOpcVarD(2));
cont7.mvDes(n) = 0;
cont7.err(n) = 0;
cont7.OPCprev = cont7.OPC(1);

% Controller 8 Variable Creation
% Reads
cont8.fcv541_read = additem(cont8.grp, 'FCV_541-R1A.FCV_541.PV', 'double');
cont8.pv1_read = additem(cont8.grp, 'FCV_541-R1A.PV1.PV', 'double');
cont8.pv2_read = additem(cont8.grp, 'FCV_541-R1A.PV2.PV', 'double');
cont8.dv_read = additem(cont8.grp, 'FCV_541-R1A.DV.PV', 'double');
cont8.sp_read = additem(cont8.grp, 'FCV_541-R1A.SP.PV', 'double');
cont8.OpcVarA_read = additem(cont8.grp, 'FCV_541-R1A.OPC_VarA.PV', 'double');
cont8.OpcVarB_read = additem(cont8.grp, 'FCV_541-R1A.OPC_VarB.PV', 'double');
cont8.OpcVarC_read = additem(cont8.grp, 'FCV_541-R1A.OPC_VarC.PV', 'double');
cont8.OpcVarD_read = additem(cont8.grp, 'FCV_541-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont8.opcEnable = additem(cont8.grp, 'FCV_541-R1A.OPCenable.PVFL', 'double');

% Writes
cont8.fcv541_write = additem(cont8.grp, 'FCV_541-R1A.FCV541_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont8.fcv541_read));
tempreadPv1 = struct2cell(read(cont8.pv1_read));
tempreadPv2 = struct2cell(read(cont8.pv2_read));
tempreadDv = struct2cell(read(cont8.dv_read));
tempreadSp = struct2cell(read(cont8.sp_read));
tempOpcState = struct2cell(read(cont8.opcEnable));
tempOpcVarA = struct2cell(read(cont8.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont8.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont8.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont8.OpcVarD_read));

cont8.fcv541(n) = cell2mat(tempreadMvOut(2));
cont8.pv1(n) = cell2mat(tempreadPv1(2));
cont8.pv2(n) = cell2mat(tempreadPv2(2));
cont8.dv(n) = cell2mat(tempreadDv(2));
cont8.sp(n) = cell2mat(tempreadSp(2));
cont8.OPC(n) = cell2mat(tempOpcState(2));
cont8.OpcVarA = cell2mat(tempOpcVarA(2));
cont8.OpcVarB = cell2mat(tempOpcVarB(2));
cont8.OpcVarC = cell2mat(tempOpcVarC(2));
cont8.OpcVarD = cell2mat(tempOpcVarD(2));
cont8.mvDes(n) = 0;
cont8.err(n) = 0;
cont8.OPCprev = cont8.OPC(1);

% Controller 9 Variable Creation
% Reads
cont9.ntp561_read = additem(cont9.grp, 'NTP_REF_561-R1A.NTP_561.PV', 'double');
cont9.pv1_read = additem(cont9.grp, 'NTP_REF_561-R1A.PV1.PV', 'double');
cont9.pv2_read = additem(cont9.grp, 'NTP_REF_561-R1A.PV2.PV', 'double');
cont9.dv_read = additem(cont9.grp, 'NTP_REF_561-R1A.DV.PV', 'double');
cont9.sp_read = additem(cont9.grp, 'NTP_REF_561-R1A.SP.PV', 'double');
cont9.OpcVarA_read = additem(cont9.grp, 'NTP_REF_561-R1A.OPC_VarA.PV', 'double');
cont9.OpcVarB_read = additem(cont9.grp, 'NTP_REF_561-R1A.OPC_VarB.PV', 'double');
cont9.OpcVarC_read = additem(cont9.grp, 'NTP_REF_561-R1A.OPC_VarC.PV', 'double');
cont9.OpcVarD_read = additem(cont9.grp, 'NTP_REF_561-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont9.opcEnable = additem(cont9.grp, 'NTP_REF_561-R1A.OPCenable.PVFL', 'double');

% Writes
cont9.ntp561_write = additem(cont9.grp, 'NTP_REF_561-R1A.NTP561_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont9.ntp561_read));
tempreadPv1 = struct2cell(read(cont9.pv1_read));
tempreadPv2 = struct2cell(read(cont9.pv2_read));
tempreadDv = struct2cell(read(cont9.dv_read));
tempreadSp = struct2cell(read(cont9.sp_read));
tempOpcState = struct2cell(read(cont9.opcEnable));
tempOpcVarA = struct2cell(read(cont9.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont9.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont9.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont9.OpcVarD_read));

cont9.ntp561(n) = cell2mat(tempreadMvOut(2));
cont9.pv1(n) = cell2mat(tempreadPv1(2));
cont9.pv2(n) = cell2mat(tempreadPv2(2));
cont9.dv(n) = cell2mat(tempreadDv(2));
cont9.sp(n) = cell2mat(tempreadSp(2));
cont9.OPC(n) = cell2mat(tempOpcState(2));
cont9.OpcVarA = cell2mat(tempOpcVarA(2));
cont9.OpcVarB = cell2mat(tempOpcVarB(2));
cont9.OpcVarC = cell2mat(tempOpcVarC(2));
cont9.OpcVarD = cell2mat(tempOpcVarD(2));
cont9.mvDes(n) = 0;
cont9.err(n) = 0;
cont9.OPCprev = cont9.OPC(1);

% Controller 10 Variable Creation
% Reads
cont10.fcv570_read = additem(cont10.grp, 'FCV_570-R1A.FCV_570.PV', 'double');
cont10.pv1_read = additem(cont10.grp, 'FCV_570-R1A.PV1.PV', 'double');
cont10.pv2_read = additem(cont10.grp, 'FCV_570-R1A.PV2.PV', 'double');
cont10.dv_read = additem(cont10.grp, 'FCV_570-R1A.DV.PV', 'double');
cont10.sp_read = additem(cont10.grp, 'FCV_570-R1A.SP.PV', 'double');
cont10.OpcVarA_read = additem(cont10.grp, 'FCV_570-R1A.OPC_VarA.PV', 'double');
cont10.OpcVarB_read = additem(cont10.grp, 'FCV_570-R1A.OPC_VarB.PV', 'double');
cont10.OpcVarC_read = additem(cont10.grp, 'FCV_570-R1A.OPC_VarC.PV', 'double');
cont10.OpcVarD_read = additem(cont10.grp, 'FCV_570-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont10.opcEnable = additem(cont10.grp, 'FCV_570-R1A.OPCenable.PVFL', 'double');

% Writes
cont10.fcv570_write = additem(cont10.grp, 'FCV_570-R1A.FCV570_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont10.fcv570_read));
tempreadPv1 = struct2cell(read(cont10.pv1_read));
tempreadPv2 = struct2cell(read(cont10.pv2_read));
tempreadDv = struct2cell(read(cont10.dv_read));
tempreadSp = struct2cell(read(cont10.sp_read));
tempOpcState = struct2cell(read(cont10.opcEnable));
tempOpcVarA = struct2cell(read(cont10.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont10.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont10.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont10.OpcVarD_read));

cont10.fcv541(n) = cell2mat(tempreadMvOut(2));
cont10.pv1(n) = cell2mat(tempreadPv1(2));
cont10.pv2(n) = cell2mat(tempreadPv2(2));
cont10.dv(n) = cell2mat(tempreadDv(2));
cont10.sp(n) = cell2mat(tempreadSp(2));
cont10.OPC(n) = cell2mat(tempOpcState(2));
cont10.OpcVarA = cell2mat(tempOpcVarA(2));
cont10.OpcVarB = cell2mat(tempOpcVarB(2));
cont10.OpcVarC = cell2mat(tempOpcVarC(2));
cont10.OpcVarD = cell2mat(tempOpcVarD(2));
cont10.mvDes(n) = 0;
cont10.err(n) = 0;
cont10.OPCprev = cont10.OPC(1);

% Controller 11 Variable Creation
    % Controller 11 group unestablished [FCV-574 OOC]

% Controller 12 Variable Creation
    % Controller 12 group unestablished [FCV-622 OOC]

% Controller 13 Variable Creation
% Reads
cont13.fcv642_read = additem(cont13.grp, 'FCV_642-R1A.FCV_642.PV', 'double');
cont13.pv1_read = additem(cont13.grp, 'FCV_642-R1A.PV1.PV', 'double');
cont13.pv2_read = additem(cont13.grp, 'FCV_642-R1A.PV2.PV', 'double');
cont13.dv_read = additem(cont13.grp, 'FCV_642-R1A.DV.PV', 'double');
cont13.sp_read = additem(cont13.grp, 'FCV_642-R1A.SP.PV', 'double');
cont13.OpcVarA_read = additem(cont13.grp, 'FCV_642-R1A.OPC_VarA.PV', 'double');
cont13.OpcVarB_read = additem(cont13.grp, 'FCV_642-R1A.OPC_VarB.PV', 'double');
cont13.OpcVarC_read = additem(cont13.grp, 'FCV_642-R1A.OPC_VarC.PV', 'double');
cont13.OpcVarD_read = additem(cont13.grp, 'FCV_642-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont13.opcEnable = additem(cont13.grp, 'FCV_642-R1A.OPCenable.PVFL', 'double');

% Writes
cont13.fcv642_write = additem(cont13.grp, 'FCV_642-R1A.FCV642_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont13.fcv642_read));
tempreadPv1 = struct2cell(read(cont13.pv1_read));
tempreadPv2 = struct2cell(read(cont13.pv2_read));
tempreadDv = struct2cell(read(cont13.dv_read));
tempreadSp = struct2cell(read(cont13.sp_read));
tempOpcState = struct2cell(read(cont13.opcEnable));
tempOpcVarA = struct2cell(read(cont13.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont13.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont13.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont13.OpcVarD_read));

cont13.fcv642(n) = cell2mat(tempreadMvOut(2));
cont13.pv1(n) = cell2mat(tempreadPv1(2));
cont13.pv2(n) = cell2mat(tempreadPv2(2));
cont13.dv(n) = cell2mat(tempreadDv(2));
cont13.sp(n) = cell2mat(tempreadSp(2));
cont13.OPC(n) = cell2mat(tempOpcState(2));
cont13.OpcVarA = cell2mat(tempOpcVarA(2));
cont13.OpcVarB = cell2mat(tempOpcVarB(2));
cont13.OpcVarC = cell2mat(tempOpcVarC(2));
cont13.OpcVarD = cell2mat(tempOpcVarD(2));
cont13.mvDes(n) = 0;
cont13.err(n) = 0;
cont13.OPCprev = cont13.OPC(1);

% Controller 14 Variable Creation
% Reads
cont14.fcv662_read = additem(cont14.grp, 'FCV_662-R1A.FCV_662.PV', 'double');
cont14.pv1_read = additem(cont14.grp, 'FCV_662-R1A.PV1.PV', 'double');
cont14.pv2_read = additem(cont14.grp, 'FCV_662-R1A.PV2.PV', 'double');
cont14.dv_read = additem(cont14.grp, 'FCV_662-R1A.DV.PV', 'double');
cont14.sp_read = additem(cont14.grp, 'FCV_662-R1A.SP.PV', 'double');
cont14.OpcVarA_read = additem(cont14.grp, 'FCV_662-R1A.OPC_VarA.PV', 'double');
cont14.OpcVarB_read = additem(cont14.grp, 'FCV_662-R1A.OPC_VarB.PV', 'double');
cont14.OpcVarC_read = additem(cont14.grp, 'FCV_662-R1A.OPC_VarC.PV', 'double');
cont14.OpcVarD_read = additem(cont14.grp, 'FCV_662-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont14.opcEnable = additem(cont14.grp, 'FCV_662-R1A.OPCenable.PVFL', 'double');

% Writes
cont14.fcv662_write = additem(cont14.grp, 'FCV_662-R1A.FCV662_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont14.fcv662_read));
tempreadPv1 = struct2cell(read(cont14.pv1_read));
tempreadPv2 = struct2cell(read(cont14.pv2_read));
tempreadDv = struct2cell(read(cont14.dv_read));
tempreadSp = struct2cell(read(cont14.sp_read));
tempOpcState = struct2cell(read(cont14.opcEnable));
tempOpcVarA = struct2cell(read(cont14.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont14.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont14.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont14.OpcVarD_read));

cont14.fcv662(n) = cell2mat(tempreadMvOut(2));
cont14.pv1(n) = cell2mat(tempreadPv1(2));
cont14.pv2(n) = cell2mat(tempreadPv2(2));
cont14.dv(n) = cell2mat(tempreadDv(2));
cont14.sp(n) = cell2mat(tempreadSp(2));
cont14.OPC(n) = cell2mat(tempOpcState(2));
cont14.OpcVarA = cell2mat(tempOpcVarA(2));
cont14.OpcVarB = cell2mat(tempOpcVarB(2));
cont14.OpcVarC = cell2mat(tempOpcVarC(2));
cont14.OpcVarD = cell2mat(tempOpcVarD(2));
cont14.mvDes(n) = 0;
cont14.err(n) = 0;
cont14.OPCprev = cont14.OPC(1);

% Controller 15 Variable Creation
% Reads
cont15.fcv688_read = additem(cont14.grp, 'FCV_688-R1A.FCV_688.PV', 'double');
cont15.pv1_read = additem(cont14.grp, 'FCV_688-R1A.PV1.PV', 'double');
cont15.pv2_read = additem(cont14.grp, 'FCV_688-R1A.PV2.PV', 'double');
cont15.dv_read = additem(cont14.grp, 'FCV_688-R1A.DV.PV', 'double');
cont15.sp_read = additem(cont14.grp, 'FCV_688-R1A.SP.PV', 'double');
cont15.OpcVarA_read = additem(cont15.grp, 'FCV_688-R1A.OPC_VarA.PV', 'double');
cont15.OpcVarB_read = additem(cont15.grp, 'FCV_688-R1A.OPC_VarB.PV', 'double');
cont15.OpcVarC_read = additem(cont15.grp, 'FCV_688-R1A.OPC_VarC.PV', 'double');
cont15.OpcVarD_read = additem(cont15.grp, 'FCV_688-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont15.opcEnable = additem(cont14.grp, 'FCV_688-R1A.OPCenable.PVFL', 'double');

% Writes
cont15.fcv688_write = additem(cont14.grp, 'FCV_688-R1A.FCV688_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont15.fcv688_read));
tempreadPv1 = struct2cell(read(cont15.pv1_read));
tempreadPv2 = struct2cell(read(cont15.pv2_read));
tempreadDv = struct2cell(read(cont15.dv_read));
tempreadSp = struct2cell(read(cont15.sp_read));
tempOpcState = struct2cell(read(cont15.opcEnable));
tempOpcVarA = struct2cell(read(cont15.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont15.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont15.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont15.OpcVarD_read));

cont15.fcv688(n) = cell2mat(tempreadMvOut(2));
cont15.pv1(n) = cell2mat(tempreadPv1(2));
cont15.pv2(n) = cell2mat(tempreadPv2(2));
cont15.dv(n) = cell2mat(tempreadDv(2));
cont15.sp(n) = cell2mat(tempreadSp(2));
cont15.OPC(n) = cell2mat(tempOpcState(2));
cont15.OpcVarA = cell2mat(tempOpcVarA(2));
cont15.OpcVarB = cell2mat(tempOpcVarB(2));
cont15.OpcVarC = cell2mat(tempOpcVarC(2));
cont15.OpcVarD = cell2mat(tempOpcVarD(2));
cont15.mvDes(n) = 0;
cont15.err(n) = 0;
cont15.OPCprev = cont15.OPC(1);

% Controller 16 Variable Creation
% Reads
cont16.fcv690_read = additem(cont16.grp, 'FCV_690-R1A.FCV_690.PV', 'double');
cont16.pv1_read = additem(cont16.grp, 'FCV_690-R1A.PV1.PV', 'double');
cont16.pv2_read = additem(cont16.grp, 'FCV_690-R1A.PV2.PV', 'double');
cont16.dv_read = additem(cont16.grp, 'FCV_690-R1A.DV.PV', 'double');
cont16.sp_read = additem(cont16.grp, 'FCV_690-R1A.SP.PV', 'double');
cont16.OpcVarA_read = additem(cont16.grp, 'FCV_690-R1A.OPC_VarA.PV', 'double');
cont16.OpcVarB_read = additem(cont16.grp, 'FCV_690-R1A.OPC_VarB.PV', 'double');
cont16.OpcVarC_read = additem(cont16.grp, 'FCV_690-R1A.OPC_VarC.PV', 'double');
cont16.OpcVarD_read = additem(cont16.grp, 'FCV_690-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont16.opcEnable = additem(cont16.grp, 'FCV_690-R1A.OPCenable.PVFL', 'double');

% Writes
cont16.fcv690_write = additem(cont16.grp, 'FCV_690-R1A.FCV690_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont16.fcv690_read));
tempreadPv1 = struct2cell(read(cont16.pv1_read));
tempreadPv2 = struct2cell(read(cont16.pv2_read));
tempreadDv = struct2cell(read(cont16.dv_read));
tempreadSp = struct2cell(read(cont16.sp_read));
tempOpcState = struct2cell(read(cont16.opcEnable));
tempOpcVarA = struct2cell(read(cont16.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont16.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont16.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont16.OpcVarD_read));

cont16.fcv690(n) = cell2mat(tempreadMvOut(2));
cont16.pv1(n) = cell2mat(tempreadPv1(2));
cont16.pv2(n) = cell2mat(tempreadPv2(2));
cont16.dv(n) = cell2mat(tempreadDv(2));
cont16.sp(n) = cell2mat(tempreadSp(2));
cont16.OPC(n) = cell2mat(tempOpcState(2));
cont16.OpcVarA = cell2mat(tempOpcVarA(2));
cont16.OpcVarB = cell2mat(tempOpcVarB(2));
cont16.OpcVarC = cell2mat(tempOpcVarC(2));
cont16.OpcVarD = cell2mat(tempOpcVarD(2));
cont16.mvDes(n) = 0;
cont16.err(n) = 0;
cont16.OPCprev = cont16.OPC(1);

% Controller 17 Variable Creation
% Reads
cont17.pp681_read = additem(cont17.grp, 'PP_REF_681-R1A.PP_681.PV', 'double');
cont17.pv1_read = additem(cont17.grp, 'PP_REF_681-R1A.PV1.PV', 'double');
cont17.pv2_read = additem(cont17.grp, 'PP_REF_681-R1A.PV2.PV', 'double');
cont17.dv_read = additem(cont17.grp, 'PP_REF_681-R1A.DV.PV', 'double');
cont17.sp_read = additem(cont17.grp, 'PP_REF_681-R1A.SP.PV', 'double');
cont17.OpcVarA_read = additem(cont17.grp, 'PP_REF_681-R1A.OPC_VarA.PV', 'double');
cont17.OpcVarB_read = additem(cont17.grp, 'PP_REF_681-R1A.OPC_VarB.PV', 'double');
cont17.OpcVarC_read = additem(cont17.grp, 'PP_REF_681-R1A.OPC_VarC.PV', 'double');
cont17.OpcVarD_read = additem(cont17.grp, 'PP_REF_681-R1A.OPC_VarD.PV', 'double');

% Read/Write
cont17.opcEnable = additem(cont17.grp, 'PP_REF_681-R1A.OPCenable.PVFL', 'double');

% Writes
cont17.pp681_write = additem(cont17.grp, 'PP_REF_681-R1A.PP681_OPC.PV', 'double');

% initialize controller variables
tempreadMvOut = struct2cell(read(cont17.pp681_read));
tempreadPv1 = struct2cell(read(cont17.pv1_read));
tempreadPv2 = struct2cell(read(cont17.pv2_read));
tempreadDv = struct2cell(read(cont17.dv_read));
tempreadSp = struct2cell(read(cont17.sp_read));
tempOpcState = struct2cell(read(cont17.opcEnable));
tempOpcVarA = struct2cell(read(cont17.OpcVarA_read));
tempOpcVarB = struct2cell(read(cont17.OpcVarB_read));
tempOpcVarC = struct2cell(read(cont17.OpcVarC_read));
tempOpcVarD = struct2cell(read(cont17.OpcVarD_read));

cont17.pp681(n) = cell2mat(tempreadMvOut(2));
cont17.pv1(n) = cell2mat(tempreadPv1(2));
cont17.pv2(n) = cell2mat(tempreadPv2(2));
cont17.dv(n) = cell2mat(tempreadDv(2));
cont17.sp(n) = cell2mat(tempreadSp(2));
cont17.OPC(n) = cell2mat(tempOpcState(2));
cont17.OpcVarA = cell2mat(tempOpcVarA(2));
cont17.OpcVarB = cell2mat(tempOpcVarB(2));
cont17.OpcVarC = cell2mat(tempOpcVarC(2));
cont17.OpcVarD = cell2mat(tempOpcVarD(2));
cont17.mvDes(n) = 0;
cont17.err(n) = 0;
cont17.OPCprev = cont17.OPC(1);

% Controller 18 Variable Creation
    % (18) SPARE CONTROLLER

% Controller 19 Variable Creation
    % Controller 19 group unestablished [FCV-571 OOC]

% Controller 20 Variable Creation
    % (20) SPARE CONTROLLER

%%           3b: Bonus Variables Creation and First Read
%               Use this field to create additional variables for use in
%               controllers, for example to add variables for flow
%               transmitter 148, noting bonus.ft148grp variable established 
%               in section 2b:
%
%   bonus.ft148read = additem(bonus.ft148grp, 'FT_148.FT_148.PV', 'double);
%   tempreadft148 = struct2cell(read(bonus.ft148read)); \
%   bonus.ft148(n) = cell2mat(tempreadft148(2));        /   <-- first read


%%       II. Main Loop (Controllers)
while true
    timePassed = toc;          %    \
    if timePassed < dt         %     | If time since last timer reading 
        pause(dt - timePassed) %     | less than dt, wait sufficent time
    else                       %     | to make sample time = dt, else 
        disp(timePassed)       %     | alert user
    end                        %    /  
    tic % reset timer  
    
    n = n + 1; t(n) = (n-1)*dt; % progress n & t

    %%           3c: Bonus Variables Read
    %               Use this field to read variables created in section 3b
    %   tempreadft148 = struct2cell(read(bonus.ft148read)); \
    %   bonus.ft148(n) = cell2mat(tempreadft148(2));        /   <-- nth read

    %%           4: Controller 1, [FP-141 (BMT input pump)]
    cont1.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont1.fp141_read));
    tempreadPv1 = struct2cell(read(cont1.pv1_read));
    tempreadPv2 = struct2cell(read(cont1.pv2_read));
    tempreadDv = struct2cell(read(cont1.dv_read));
    tempreadSp = struct2cell(read(cont1.sp_read));
    tempOpcState = struct2cell(read(cont1.opcEnable));
    tempOpcVarA = struct2cell(read(cont1.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont1.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont1.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont1.OpcVarD_read));
    
    cont1.fp141(n) = cell2mat(tempreadMvOut(2));
    cont1.pv1(n) = cell2mat(tempreadPv1(2));
    cont1.pv2(n) = cell2mat(tempreadPv2(2));
    cont1.dv(n) = cell2mat(tempreadDv(2));
    cont1.sp(n) = cell2mat(tempreadSp(2));
    cont1.OPC(n) = cell2mat(tempOpcState(2));
    cont1.OpcVarA = cell2mat(tempOpcVarA(2));
    cont1.OpcVarB = cell2mat(tempOpcVarB(2));
    cont1.OpcVarC = cell2mat(tempOpcVarC(2));
    cont1.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont1.OPC(n) == 1 && cont1.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ------------------ FP141 Controller Goes Here ----------------------
    % ####################################################################
    % ####################################################################
        cont1.K = cont1.OpcVarA;
        cont1.ti = cont1.OpcVarB;

        cont1.err(n) = cont1.sp(n) - cont1.pv1(n);
        tempmvDes = cont1.mvDes(n-1) + cont1.K*((1+(dt/cont1.ti))...
                    *cont1.err(n) - cont1.err(n-1)); 
        if tempmvDes > 105
            cont1.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont1.mvDes(n) = -5;
        else
            cont1.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont1.OPC(n) == 1 && cont1.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont1.opcEnable, 0); % < Disable OPC in EPKS
        cont1.err(n) = 0;
        cont1.mvDes(n) = cont1.fp141(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont1.err(n) = 0;
        cont1.mvDes(n) = cont1.fp141(n);
    end

    % Write MV to EPKS
    write(cont1.fp141_write, cont1.mvDes(n));
    cont1.OPCprev = cont1.OPC(n);

    %%           5: Controller 2, [BM-201 (Ball Mill Speed)] *OOC*
        % This asset is currently out of commission, leave empty until
        % asset is operational.
        %          ██████   ██████   ██████ 
        %         ██    ██ ██    ██ ██      
        %         ██    ██ ██    ██ ██      
        %          ██████   ██████   ██████ 

    %%           6: Controller 3, [BMP-241 (BMT output pump)]
    cont3.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont3.bmp241_read));
    tempreadPv1 = struct2cell(read(cont3.pv1_read));
    tempreadPv2 = struct2cell(read(cont3.pv2_read));
    tempreadDv = struct2cell(read(cont3.dv_read));
    tempreadSp = struct2cell(read(cont3.sp_read));
    tempOpcState = struct2cell(read(cont3.opcEnable));
    tempOpcVarA = struct2cell(read(cont3.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont3.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont3.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont3.OpcVarD_read));
    
    cont3.bmp241(n) = cell2mat(tempreadMvOut(2));
    cont3.pv1(n) = cell2mat(tempreadPv1(2));
    cont3.pv2(n) = cell2mat(tempreadPv2(2));
    cont3.dv(n) = cell2mat(tempreadDv(2));
    cont3.sp(n) = cell2mat(tempreadSp(2));
    cont3.OPC(n) = cell2mat(tempOpcState(2));
    cont3.OpcVarA = cell2mat(tempOpcVarA(2));
    cont3.OpcVarB = cell2mat(tempOpcVarB(2));
    cont3.OpcVarC = cell2mat(tempOpcVarC(2));
    cont3.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont3.OPC(n) == 1 && cont3.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ------------------ BMP241 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont3.K = cont3.OpcVarA;
        cont3.ti = cont3.OpcVarB;

        cont3.err(n) = cont3.sp(n) - cont3.pv1(n);
        tempmvDes = cont3.mvDes(n-1) + cont3.K*((1+(dt/cont3.ti))...
                    *cont3.err(n) - cont3.err(n-1)); 
        if tempmvDes > 105
            cont3.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont3.mvDes(n) = -5;
        else
            cont3.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont3.OPC(n) == 1 && cont3.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont3.opcEnable, 0); % < Disable OPC in EPKS
        cont3.err(n) = 0;
        cont3.mvDes(n) = cont3.bmp241(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont3.err(n) = 0;
        cont3.mvDes(n) = cont3.bmp241(n);
    end

    % Write MV to EPKS
    write(cont3.bmp241_write, cont3.mvDes(n));
    cont3.OPCprev = cont3.OPC(n);

    %%           7: Controller 4, [CRP-341 (Cyclone Recycle Pump)]
    cont4.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont4.crp341_read));
    tempreadPv1 = struct2cell(read(cont4.pv1_read));
    tempreadPv2 = struct2cell(read(cont4.pv2_read));
    tempreadDv = struct2cell(read(cont4.dv_read));
    tempreadSp = struct2cell(read(cont4.sp_read));
    tempOpcState = struct2cell(read(cont4.opcEnable));
    tempOpcVarA = struct2cell(read(cont4.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont4.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont4.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont4.OpcVarD_read));
    
    cont4.crp341(n) = cell2mat(tempreadMvOut(2));
    cont4.pv1(n) = cell2mat(tempreadPv1(2));
    cont4.pv2(n) = cell2mat(tempreadPv2(2));
    cont4.dv(n) = cell2mat(tempreadDv(2));
    cont4.sp(n) = cell2mat(tempreadSp(2));
    cont4.OPC(n) = cell2mat(tempOpcState(2));
    cont4.OpcVarA = cell2mat(tempOpcVarA(2));
    cont4.OpcVarB = cell2mat(tempOpcVarB(2));
    cont4.OpcVarC = cell2mat(tempOpcVarC(2));
    cont4.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont4.OPC(n) == 1 && cont4.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ------------------ CRP-341 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont4.K = cont4.OpcVarA;
        cont4.ti = cont4.OpcVarB;

        cont4.err(n) = cont4.sp(n) - cont4.pv1(n);
        tempmvDes = cont4.mvDes(n-1) + cont4.K*((1+(dt/cont4.ti))...
                    *cont4.err(n) - cont4.err(n-1)); 
        if tempmvDes > 105
            cont4.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont4.mvDes(n) = -5;
        else
            cont4.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont4.OPC(n) == 1 && cont4.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont4.opcEnable, 0); % < Disable OPC in EPKS
        cont4.err(n) = 0;
        cont4.mvDes(n) = cont4.crp341(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont4.err(n) = 0;
        cont4.mvDes(n) = cont4.crp341(n);
    end

    % Write MV to EPKS
    write(cont4.crp341_write, cont4.mvDes(n));
    cont4.OPCprev = cont4.OPC(n);

    %%           8: Controller 5, [CUFP-361 (Cyclone Underflow Pump)]
    cont5.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont5.cufp361_read));
    tempreadPv1 = struct2cell(read(cont5.pv1_read));
    tempreadPv2 = struct2cell(read(cont5.pv2_read));
    tempreadDv = struct2cell(read(cont5.dv_read));
    tempreadSp = struct2cell(read(cont5.sp_read));
    tempOpcState = struct2cell(read(cont5.opcEnable));
    tempOpcVarA = struct2cell(read(cont5.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont5.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont5.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont5.OpcVarD_read));
    
    cont5.cufp361(n) = cell2mat(tempreadMvOut(2));
    cont5.pv1(n) = cell2mat(tempreadPv1(2));
    cont5.pv2(n) = cell2mat(tempreadPv2(2));
    cont5.dv(n) = cell2mat(tempreadDv(2));
    cont5.sp(n) = cell2mat(tempreadSp(2));
    cont5.OPC(n) = cell2mat(tempOpcState(2));
    cont5.OpcVarA = cell2mat(tempOpcVarA(2));
    cont5.OpcVarB = cell2mat(tempOpcVarB(2));
    cont5.OpcVarC = cell2mat(tempOpcVarC(2));
    cont5.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont5.OPC(n) == 1 && cont5.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- CUFP-361 Controller Goes Here --------------------
    % ####################################################################
    % ####################################################################
        cont5.K = cont5.OpcVarA;
        cont5.ti = cont5.OpcVarB;

        cont5.err(n) = cont5.sp(n) - cont5.pv1(n);
        tempmvDes = cont5.mvDes(n-1) + cont5.K*((1+(dt/cont5.ti))...
                    *cont5.err(n) - cont5.err(n-1)); 
        if tempmvDes > 105
            cont5.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont5.mvDes(n) = -5;
        else
            cont5.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont5.OPC(n) == 1 && cont5.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont5.opcEnable, 0); % < Disable OPC in EPKS
        cont5.err(n) = 0;
        cont5.mvDes(n) = cont5.cufp361(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont5.err(n) = 0;
        cont5.mvDes(n) = cont5.cufp361(n);
    end

    % Write MV to EPKS
    write(cont5.cufp361_write, cont5.mvDes(n));
    cont5.OPCprev = cont5.OPC(n);


    %%           9: Controller 6, [LUFP-421 (Lamella Underflow Pump)]



    %%           10: Controller 7, [FDP-521 (Feed Disturbance Pump)]
    cont7.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont7.fdp521_read));
    tempreadPv1 = struct2cell(read(cont7.pv1_read));
    tempreadPv2 = struct2cell(read(cont7.pv2_read));
    tempreadDv = struct2cell(read(cont7.dv_read));
    tempreadSp = struct2cell(read(cont7.sp_read));
    tempOpcState = struct2cell(read(cont7.opcEnable));
    tempOpcVarA = struct2cell(read(cont7.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont7.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont7.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont7.OpcVarD_read));
        
    cont7.fdp521(n) = cell2mat(tempreadMvOut(2));
    cont7.pv1(n) = cell2mat(tempreadPv1(2));
    cont7.pv2(n) = cell2mat(tempreadPv2(2));
    cont7.dv(n) = cell2mat(tempreadDv(2));
    cont7.sp(n) = cell2mat(tempreadSp(2));
    cont7.OPC(n) = cell2mat(tempOpcState(2));
    cont7.OpcVarA = cell2mat(tempOpcVarA(2));
    cont7.OpcVarB = cell2mat(tempOpcVarB(2));
    cont7.OpcVarC = cell2mat(tempOpcVarC(2));
    cont7.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont7.OPC(n) == 1 && cont7.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FDP-521 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont7.K = cont7.OpcVarA;
        cont7.ti = cont7.OpcVarB;

        cont7.err(n) = cont7.sp(n) - cont7.pv1(n);
        tempmvDes = cont7.mvDes(n-1) + cont7.K*((1+(dt/cont7.ti))...
                    *cont7.err(n) - cont7.err(n-1)); 
        if tempmvDes > 105
            cont7.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont7.mvDes(n) = -5;
        else
            cont7.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont7.OPC(n) == 1 && cont7.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont7.opcEnable, 0); % < Disable OPC in EPKS
        cont7.err(n) = 0;
        cont7.mvDes(n) = cont7.fdp521(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont7.err(n) = 0;
        cont7.mvDes(n) = cont7.fdp521(n);
    end

    % Write MV to EPKS
    write(cont7.fdp521_write, cont7.mvDes(n));
    cont7.OPCprev = cont7.OPC(n);

    %%           11: Controller 8, [FCV-541 (NLT input)]
    cont8.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont8.fcv541_read));
    tempreadPv1 = struct2cell(read(cont8.pv1_read));
    tempreadPv2 = struct2cell(read(cont8.pv2_read));
    tempreadDv = struct2cell(read(cont8.dv_read));
    tempreadSp = struct2cell(read(cont8.sp_read));
    tempOpcState = struct2cell(read(cont8.opcEnable));
    tempOpcVarA = struct2cell(read(cont8.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont8.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont8.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont8.OpcVarD_read));
    
    cont8.fcv541(n) = cell2mat(tempreadMvOut(2));
    cont8.pv1(n) = cell2mat(tempreadPv1(2));
    cont8.pv2(n) = cell2mat(tempreadPv2(2));
    cont8.dv(n) = cell2mat(tempreadDv(2));
    cont8.sp(n) = cell2mat(tempreadSp(2));
    cont8.OPC(n) = cell2mat(tempOpcState(2));
    cont8.OpcVarA = cell2mat(tempOpcVarA(2));
    cont8.OpcVarB = cell2mat(tempOpcVarB(2));
    cont8.OpcVarC = cell2mat(tempOpcVarC(2));
    cont8.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont8.OPC(n) == 1 && cont8.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-541 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont8.K = cont8.OpcVarA;
        cont8.ti = cont8.OpcVarB;

        cont8.err(n) = cont8.sp(n) - cont8.pv1(n);
        tempmvDes = cont8.mvDes(n-1) + cont8.K*((1+(dt/cont8.ti))...
                    *cont8.err(n) - cont8.err(n-1)); 
        if tempmvDes > 105
            cont8.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont8.mvDes(n) = -5;
        else
            cont8.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont8.OPC(n) == 1 && cont8.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont8.opcEnable, 0); % < Disable OPC in EPKS
        cont8.err(n) = 0;
        cont8.mvDes(n) = cont8.fcv541(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont8.err(n) = 0;
        cont8.mvDes(n) = cont8.fcv541(n);
    end

    % Write MV to EPKS
    write(cont8.fcv541_write, cont8.mvDes(n));
    cont8.OPCprev = cont8.OPC(n);

    %%           12: Controller 9, [NTP-561 (Needle Tank Underflow Pump)]
    cont9.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont9.ntp561_read));
    tempreadPv1 = struct2cell(read(cont9.pv1_read));
    tempreadPv2 = struct2cell(read(cont9.pv2_read));
    tempreadDv = struct2cell(read(cont9.dv_read));
    tempreadSp = struct2cell(read(cont9.sp_read));
    tempOpcState = struct2cell(read(cont9.opcEnable));
    tempOpcVarA = struct2cell(read(cont9.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont9.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont9.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont9.OpcVarD_read));
    
    cont9.ntp561(n) = cell2mat(tempreadMvOut(2));
    cont9.pv1(n) = cell2mat(tempreadPv1(2));
    cont9.pv2(n) = cell2mat(tempreadPv2(2));
    cont9.dv(n) = cell2mat(tempreadDv(2));
    cont9.sp(n) = cell2mat(tempreadSp(2));
    cont9.OPC(n) = cell2mat(tempOpcState(2));
    cont9.OpcVarA = cell2mat(tempOpcVarA(2));
    cont9.OpcVarB = cell2mat(tempOpcVarB(2));
    cont9.OpcVarC = cell2mat(tempOpcVarC(2));
    cont9.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont9.OPC(n) == 1 && cont9.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- NTP-561 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont9.K = cont9.OpcVarA;
        cont9.ti = cont9.OpcVarB;

        cont9.err(n) = cont9.sp(n) - cont9.pv1(n);
        tempmvDes = cont9.mvDes(n-1) + cont9.K*((1+(dt/cont9.ti))...
                    *cont9.err(n) - cont9.err(n-1)); 
        if tempmvDes > 105
            cont9.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont9.mvDes(n) = -5;
        else
            cont9.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont9.OPC(n) == 1 && cont9.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont9.opcEnable, 0); % < Disable OPC in EPKS
        cont9.err(n) = 0;
        cont9.mvDes(n) = cont9.ntp561(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont9.err(n) = 0;
        cont9.mvDes(n) = cont9.ntp561(n);
    end

    % Write MV to EPKS
    write(cont9.ntp561_write, cont9.mvDes(n));
    cont9.OPCprev = cont9.OPC(n);

    %%           13: Controller 10, [FCV-570 (CSTR1 fluid input)]
    cont10.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont10.fcv570_read));
    tempreadPv1 = struct2cell(read(cont10.pv1_read));
    tempreadPv2 = struct2cell(read(cont10.pv2_read));
    tempreadDv = struct2cell(read(cont10.dv_read));
    tempreadSp = struct2cell(read(cont10.sp_read));
    tempOpcState = struct2cell(read(cont10.opcEnable));
    tempOpcVarA = struct2cell(read(cont10.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont10.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont10.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont10.OpcVarD_read));
    
    cont10.fcv541(n) = cell2mat(tempreadMvOut(2));
    cont10.pv1(n) = cell2mat(tempreadPv1(2));
    cont10.pv2(n) = cell2mat(tempreadPv2(2));
    cont10.dv(n) = cell2mat(tempreadDv(2));
    cont10.sp(n) = cell2mat(tempreadSp(2));
    cont10.OPC(n) = cell2mat(tempOpcState(2));
    cont10.OpcVarA = cell2mat(tempOpcVarA(2));
    cont10.OpcVarB = cell2mat(tempOpcVarB(2));
    cont10.OpcVarC = cell2mat(tempOpcVarC(2));
    cont10.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont10.OPC(n) == 1 && cont10.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-570 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont10.K = cont10.OpcVarA;
        cont10.ti = cont10.OpcVarB;

        cont10.err(n) = cont10.sp(n) - cont10.pv1(n);
        tempmvDes = cont10.mvDes(n-1) + cont10.K*((1+(dt/cont10.ti))...
                    *cont10.err(n) - cont10.err(n-1)); 
        if tempmvDes > 105
            cont10.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont10.mvDes(n) = -5;
        else
            cont10.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont10.OPC(n) == 1 && cont10.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont10.opcEnable, 0); % < Disable OPC in EPKS
        cont10.err(n) = 0;
        cont10.mvDes(n) = cont10.fcv541(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont10.err(n) = 0;
        cont10.mvDes(n) = cont10.fcv570(n);
    end

    % Write MV to EPKS
    write(cont10.fcv570_write, cont10.mvDes(n));
    cont10.OPCprev = cont10.OPC(n);

    %%           14: Controller 11, [FCV-574 (NT to BMT)] *OOC*
        % This asset is currently out of commission, leave empty until
        % asset is operational.
        %          ██████   ██████   ██████ 
        %         ██    ██ ██    ██ ██      
        %         ██    ██ ██    ██ ██      
        %          ██████   ██████   ██████ 

    %%           15: Controller 12, [FCV-662 (CSTR1 Steam In)] *OOC*
        % This asset is currently out of commission, leave empty until
        % asset is operational.
        %          ██████   ██████   ██████ 
        %         ██    ██ ██    ██ ██      
        %         ██    ██ ██    ██ ██      
        %          ██████   ██████   ██████ 

    %%           16: Controller 13, [FCV-642 (CSTR2 Steam In)]
    cont13.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont13.fcv642_read));
    tempreadPv1 = struct2cell(read(cont13.pv1_read));
    tempreadPv2 = struct2cell(read(cont13.pv2_read));
    tempreadDv = struct2cell(read(cont13.dv_read));
    tempreadSp = struct2cell(read(cont13.sp_read));
    tempOpcState = struct2cell(read(cont13.opcEnable));
    tempOpcVarA = struct2cell(read(cont13.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont13.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont13.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont13.OpcVarD_read));
    
    cont13.fcv642(n) = cell2mat(tempreadMvOut(2));
    cont13.pv1(n) = cell2mat(tempreadPv1(2));
    cont13.pv2(n) = cell2mat(tempreadPv2(2));
    cont13.dv(n) = cell2mat(tempreadDv(2));
    cont13.sp(n) = cell2mat(tempreadSp(2));
    cont13.OPC(n) = cell2mat(tempOpcState(2));
    cont13.OpcVarA = cell2mat(tempOpcVarA(2));
    cont13.OpcVarB = cell2mat(tempOpcVarB(2));
    cont13.OpcVarC = cell2mat(tempOpcVarC(2));
    cont13.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont13.OPC(n) == 1 && cont13.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-642 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont13.K = cont13.OpcVarA;
        cont13.ti = cont13.OpcVarB;

        cont13.err(n) = cont13.sp(n) - cont13.pv1(n);
        tempmvDes = cont13.mvDes(n-1) + cont13.K*((1+(dt/cont13.ti))...
                    *cont13.err(n) - cont13.err(n-1)); 
        if tempmvDes > 105
            cont13.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont13.mvDes(n) = -5;
        else
            cont13.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont13.OPC(n) == 1 && cont13.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont13.opcEnable, 0); % < Disable OPC in EPKS
        cont13.err(n) = 0;
        cont13.mvDes(n) = cont13.fcv642(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont13.err(n) = 0;
        cont13.mvDes(n) = cont13.fcv642(n);
    end

    % Write MV to EPKS
    write(cont13.fcv642_write, cont13.mvDes(n));
    cont13.OPCprev = cont13.OPC(n);

    %%           17: Controller 14, [FCV-662 (CSTR3 Steam In)]
    cont14.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont14.fcv662_read));
    tempreadPv1 = struct2cell(read(cont14.pv1_read));
    tempreadPv2 = struct2cell(read(cont14.pv2_read));
    tempreadDv = struct2cell(read(cont14.dv_read));
    tempreadSp = struct2cell(read(cont14.sp_read));
    tempOpcState = struct2cell(read(cont14.opcEnable));
    tempOpcVarA = struct2cell(read(cont14.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont14.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont14.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont14.OpcVarD_read));

    cont14.fcv662(n) = cell2mat(tempreadMvOut(2));
    cont14.pv1(n) = cell2mat(tempreadPv1(2));
    cont14.pv2(n) = cell2mat(tempreadPv2(2));
    cont14.dv(n) = cell2mat(tempreadDv(2));
    cont14.sp(n) = cell2mat(tempreadSp(2));
    cont14.OPC(n) = cell2mat(tempOpcState(2));
    cont14.OpcVarA = cell2mat(tempOpcVarA(2));
    cont14.OpcVarB = cell2mat(tempOpcVarB(2));
    cont14.OpcVarC = cell2mat(tempOpcVarC(2));
    cont14.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont14.OPC(n) == 1 && cont14.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-662 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont14.K = cont14.OpcVarA;
        cont14.ti = cont14.OpcVarB;

        cont14.err(n) = cont14.sp(n) - cont14.pv1(n);
        tempmvDes = cont14.mvDes(n-1) + cont14.K*((1+(dt/cont14.ti))...
                    *cont14.err(n) - cont14.err(n-1)); 
        if tempmvDes > 105
            cont14.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont14.mvDes(n) = -5;
        else
            cont14.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont14.OPC(n) == 1 && cont14.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont14.opcEnable, 0); % < Disable OPC in EPKS
        cont14.err(n) = 0;
        cont14.mvDes(n) = cont14.fcv662(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont14.err(n) = 0;
        cont14.mvDes(n) = cont14.fcv662(n);
    end

    % Write MV to EPKS
    write(cont14.fcv662_write, cont14.mvDes(n));
    cont14.OPCprev = cont14.OPC(n);

    %%           18: Controller 15, [FCV-688 (System Output)]
    cont15.MlOpcEnable = true; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont15.fcv688_read));
    tempreadPv1 = struct2cell(read(cont15.pv1_read));
    tempreadPv2 = struct2cell(read(cont15.pv2_read));
    tempreadDv = struct2cell(read(cont15.dv_read));
    tempreadSp = struct2cell(read(cont15.sp_read));
    tempOpcState = struct2cell(read(cont15.opcEnable));
    tempOpcVarA = struct2cell(read(cont15.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont15.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont15.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont15.OpcVarD_read));
    
    cont15.fcv688(n) = cell2mat(tempreadMvOut(2));
    cont15.pv1(n) = cell2mat(tempreadPv1(2));
    cont15.pv2(n) = cell2mat(tempreadPv2(2));
    cont15.dv(n) = cell2mat(tempreadDv(2));
    cont15.sp(n) = cell2mat(tempreadSp(2));
    cont15.OPC(n) = cell2mat(tempOpcState(2));
    cont15.OpcVarA = cell2mat(tempOpcVarA(2));
    cont15.OpcVarB = cell2mat(tempOpcVarB(2));
    cont15.OpcVarC = cell2mat(tempOpcVarC(2));
    cont15.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont15.OPC(n) == 1 && cont15.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-688 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont15.K = cont15.OpcVarA;
        cont15.ti = cont15.OpcVarB;

        cont15.err(n) = cont15.sp(n) - cont15.pv1(n);
        tempmvDes = cont15.mvDes(n-1) + cont15.K*((1+(dt/cont15.ti))...
                    *cont15.err(n) - cont15.err(n-1)); 
        if tempmvDes > 105
            cont15.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont15.mvDes(n) = -5;
        else
            cont15.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont15.OPC(n) == 1 && cont15.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont15.opcEnable, 0); % < Disable OPC in EPKS
        cont15.err(n) = 0;
        cont15.mvDes(n) = cont15.fcv688(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont15.err(n) = 0;
        cont15.mvDes(n) = cont15.fcv688(n);
    end

    % Write MV to EPKS
    write(cont15.fcv688_write, cont15.mvDes(n));
    cont15.OPCprev = cont15.OPC(n);

    %%           19: Controller 16, [FCV-690 (CSTR3 Reflux)]
    cont16.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont16.fcv690_read));
    tempreadPv1 = struct2cell(read(cont16.pv1_read));
    tempreadPv2 = struct2cell(read(cont16.pv2_read));
    tempreadDv = struct2cell(read(cont16.dv_read));
    tempreadSp = struct2cell(read(cont16.sp_read));
    tempOpcState = struct2cell(read(cont16.opcEnable));
    tempOpcVarA = struct2cell(read(cont16.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont16.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont16.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont16.OpcVarD_read));
        
    cont16.fcv690(n) = cell2mat(tempreadMvOut(2));
    cont16.pv1(n) = cell2mat(tempreadPv1(2));
    cont16.pv2(n) = cell2mat(tempreadPv2(2));
    cont16.dv(n) = cell2mat(tempreadDv(2));
    cont16.sp(n) = cell2mat(tempreadSp(2));
    cont16.OPC(n) = cell2mat(tempOpcState(2));
    cont16.OpcVarA = cell2mat(tempOpcVarA(2));
    cont16.OpcVarB = cell2mat(tempOpcVarB(2));
    cont16.OpcVarC = cell2mat(tempOpcVarC(2));
    cont16.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont16.OPC(n) == 1 && cont16.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-690 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont16.K = cont16.OpcVarA;
        cont16.ti = cont16.OpcVarB;

        cont16.err(n) = cont16.sp(n) - cont16.pv1(n);
        tempmvDes = cont16.mvDes(n-1) + cont16.K*((1+(dt/cont16.ti))...
                    *cont16.err(n) - cont16.err(n-1)); 
        if tempmvDes > 105
            cont16.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont16.mvDes(n) = -5;
        else
            cont16.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont16.OPC(n) == 1 && cont16.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont16.opcEnable, 0); % < Disable OPC in EPKS
        cont16.err(n) = 0;
        cont16.mvDes(n) = cont16.fcv690(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont16.err(n) = 0;
        cont16.mvDes(n) = cont16.fcv690(n);
    end

    % Write MV to EPKS
    write(cont16.fcv690_write, cont16.mvDes(n));
    cont16.OPCprev = cont16.OPC(n);

    %%           20: Controller 17, [PP-681 (Product Pump)]
    cont17.MlOpcEnable = false; 
        % ^^^ This be made true to enable any controllers configured in
        %   MATLAB, else 0 will be written to OPC server.

    %   updating controller Variables
    tempreadMvOut = struct2cell(read(cont17.pp681_read));
    tempreadPv1 = struct2cell(read(cont17.pv1_read));
    tempreadPv2 = struct2cell(read(cont17.pv2_read));
    tempreadDv = struct2cell(read(cont17.dv_read));
    tempreadSp = struct2cell(read(cont17.sp_read));
    tempOpcState = struct2cell(read(cont17.opcEnable));
    tempOpcVarA = struct2cell(read(cont17.OpcVarA_read));
    tempOpcVarB = struct2cell(read(cont17.OpcVarB_read));
    tempOpcVarC = struct2cell(read(cont17.OpcVarC_read));
    tempOpcVarD = struct2cell(read(cont17.OpcVarD_read));
    
    cont17.pp681(n) = cell2mat(tempreadMvOut(2));
    cont17.pv1(n) = cell2mat(tempreadPv1(2));
    cont17.pv2(n) = cell2mat(tempreadPv2(2));
    cont17.dv(n) = cell2mat(tempreadDv(2));
    cont17.sp(n) = cell2mat(tempreadSp(2));
    cont17.OPC(n) = cell2mat(tempOpcState(2));
    cont17.OpcVarA = cell2mat(tempOpcVarA(2));
    cont17.OpcVarB = cell2mat(tempOpcVarB(2));
    cont17.OpcVarC = cell2mat(tempOpcVarC(2));
    cont17.OpcVarD = cell2mat(tempOpcVarD(2));

    if (cont17.OPC(n) == 1 && cont17.MlOpcEnable == 1)
        % ^^^ If OPC is enabled in EPKS && OPC is also enabled in MATLAB
        %       *** See Line 133

    % ----------------- FCV-690 Controller Goes Here ---------------------
    % ####################################################################
    % ####################################################################
        cont17.K = cont17.OpcVarA;
        cont17.ti = cont17.OpcVarB;

        cont17.err(n) = cont17.sp(n) - cont17.pv1(n);
        tempmvDes = cont17.mvDes(n-1) + cont17.K*((1+(dt/cont17.ti))...
                    *cont17.err(n) - cont17.err(n-1)); 
        if tempmvDes > 105
            cont17.mvDes(n) = 105;
        elseif tempmvDes <-5
            cont17.mvDes(n) = -5;
        else
            cont17.mvDes(n) = tempmvDes;
        end

    % ####################################################################
    % ####################################################################
    % --------------------------------------------------------------------
    elseif (cont17.OPC(n) == 1 && cont17.MlOpcEnable == 0)
        % ^^^ if OPC is enabled in EPKS BUT is not enabled in MATLAB,
        %       disable OPC in EPKS

        write(cont17.opcEnable, 0); % < Disable OPC in EPKS
        cont17.err(n) = 0;
        cont17.mvDes(n) = cont17.pp681(n);
    else
        % \/\/ If OPC disabled in EPKS and ML make error zero and make
        %       MATLAB desired MV track EPKS outerloop MV.

        cont17.err(n) = 0;
        cont17.mvDes(n) = cont17.pp681(n);
    end

    % Write MV to EPKS
    write(cont17.pp681_write, cont17.mvDes(n));
    cont17.OPCprev = cont17.OPC(n);


    %%           21: Controller 18, [SPARE]
        % Unconfigured in EPKS

    %%           22: Controller 19, [FCV-571 (NT to ST Bank)] *OOC*
        % This asset is currently out of commission, leave empty until
        % asset is operational.
        %          ██████   ██████   ██████ 
        %         ██    ██ ██    ██ ██      
        %         ██    ██ ██    ██ ██      
        %          ██████   ██████   ██████ 


    %%           23: Controller 20, [SPARE]
        % Unconfigured in EPKS

end

%        ... ......                                                                                   
%   :!7???JJ?JJJ?777!^.                                                                               
% ~~!~::^!^~!7!~!7??JYYJ7:                                                                            
% ~^^:^^~~^~^^^!7?77!~~~!7~:                                                                          
% !!!77!~^^^^^^^:^^^^^::::^!^                                                                         
% :^^^:^^^~!!!~^::^^^^^::::.^:                                                                        
% .    ................:^~J?~!.                                                                       
%   ........     ..::^~!75G##5^                                                                       
% ..............^~~~!!!7?Y5PGG?                                                                       
%   ...::^^^~!77JYJJJJ????JY555.                                                                      
%  ..^^^!!!7777???777???7!7JYY57 ...                                     
% ..^~!!7!~~::::.....:!???!^:.:^   ..                                                                   
% ..:^^^^:..:::::.....:~7~:...:^.   .                                                                  
% ::^~~~^::.:^^::....:::.:. ..::    .                                                                 
% ^~!7777~^.~^:.::...:~^^PJ: .~.    .                                                                 
% ~!!777777:7!^::..^!J~.?5BG^^!7 ...                                                                   
% ^!7777?JJ~77!~~!?JJ~.7PGBBGYJJ                                                                      
% ^~!!!7777?777??J?77!J?7?JJJJY7                                                                      
% ~~!!!!!!!7??JJJJ7!~^....:::^!^                                                                      
% !!!7!!!!7777??7!!7~..     .:~.                                                                      
% !!!!7!!777!!!!!^:...........^                                                                       
% !!~~!!!!!!!77!:...::::..:^^^.                                                                       
% 7!~~~~~~~~!!~^^^^^^:.. ..^!:                                                                        
% 7!~~~~~~~~~^^^^^^^^::...^!:                                                                         
% ?7!!~~~^^~~~~^^^^^:::.:.::                                    .          
% ??7!!~~^^^^^^::::::...::^                                    ?B5^        
% 77??7!~^^^^^^^:::::::^~~!?~:....                            :G5Y7        
% ?77??77~^^:::::::::^~!J7:^7PGPPPGG5JJ?!^.                   YJ!~^        
% Y???777!!~^^^:::::^^~7Y5~:~75PPPPPPPYYPPPY~                Y5!~~.        
% YJ????77!!~~^^^^^^^~~7Y55^^!?PGP5J5JJJ???Y55~             5G?!~.         
% ~!?????7777!!~~~~~~~~7J5GY^^~7PPPY7JYJ7?YJYJ5?          ^BBY??~          
% 7!77?JJ?7777!!777!~~~?5PGGJ7^~JYJ7?JJJJ?7YJ??Y         ?#G5YY5YPGBBPJ!:  
% !?J777?JYJJ?77??J?7!7J5GBBJ!?77:.:755??J?7Y?7?        JBP5YYYPB#####BG5^ 
% ^~!~~~~7JJ555YYJJYYJJ5PGBP!77YY7!!?55JJ?Y?!J7!       ?G5YJ??JGG5Y???7~^!.
% J7!:~~:~!77JY5PPPP555GGBBY?PY?~^!Y!?JYPJ~?!!J7      .5J?7!!!!7~~~~^::^755
% G5?7~~:::.:!777?PGPGGBBBBYJY?^~??J?~7!J?!7Y!!J       77!!~~^YG5Y5P5?~!77!
% ^::~~~!^:^:::^::~JYJJG##BY?7:!J???J7!7??J77?!!      !7~~^^^^!7777!7!^^:::
% ~~^7!777??!::.::....:!YGBY7^?JJY7?J?~7?7??777~     YP7~^^~^^!J7!~~^:::^^~
% !7~~7?!!!!!!~^~?JJ!~~^^~!7^?5Y5P?!JJ^^!J?77?J?    YPYJ!~!777?JJJJJJ!~~~^^
% !777YYYY?!!7!~:~?J???7!!!^^JPYPJ???Y7!!7!?7??7   Y5JJJ7!~!7?J?~^::::::::
% ------------  __  __        _            _      __    __                 
% ------------  \ \/ ___ __ _( )_______   | | /| / ___ / _______  __ _ ___ 
% ------------   \  / _ / // |// __/ -_)  | |/ |/ / -_/ / __/ _ \/  ' / -_)
% ------------   /_/\___\_,_/ /_/  \__/   |__/|__/\__/_/\__/\___/_/_/_\__/ 