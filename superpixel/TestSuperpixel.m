clear; close all;clc
addpath(genpath('..\'));
%% SLIC
img=imread('E:\DevProj\Datasets\MiscData\BSD69020_C.png');
figure;set(gcf,'position',[200 200 1200 750])
subplot(2,2,1);imagesc(img);title('Original Image')
pause(0.05)

spLabel=mexSLIC(double(img),500,2500,3);
imgEdge=GetLabelEdge(img,spLabel);
subplot(2,2,2);imagesc(imgEdge);title('SLIC Result')
pause(0.05)

spLabel=mexErs(double(img),300,0.2,5.0,0);
imgEdge=GetLabelEdge(img,spLabel);
subplot(2,2,3);imagesc(imgEdge);title('ERS Result')
pause(0.05)

spLabel=mexSEEDS(img,300);
imgEdge=GetLabelEdge(img,spLabel);
subplot(2,2,4);imagesc(imgEdge);title('SEEDS Result')
pause(0.05)