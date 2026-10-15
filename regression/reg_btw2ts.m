clear all;
close all;
lt=58;

%%% read data %%%
fid = fopen('./Nino_index_NDJ_1982-2018.gdat','r');
nino = fread(fid,lt,'float32');
fid = fopen('./precip_Jeonju_DEC_1982-2018.gdat','r');
pr = fread(fid,lt,'float32');

%%% plot scatter %%%
scatter(nino,pr)

%%% draw least square fitting line %%%
hl = lsline

%%% get equation of linear regression line %%%
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
