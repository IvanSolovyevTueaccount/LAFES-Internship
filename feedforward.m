clc, clear
set(0,"DefaultFigureWindowStyle",'docked')

%% Static friction measurements

static_meas_pos = [
    158.5
    161.0
    151.4
    169.4
    166.3
    146.4
];

static_meas_neg = [
    143.2
    167.7
    125.5
    134.0
    130.1
    133.9
];

static_pos = mean(static_meas_pos);
static_neg = mean(static_meas_neg);

static = mean([static_pos static_neg])

%% Viscous

viscous_torques = [
    5
    10
    15
    20
    25
    30
];

viscous_meas_pos = [
    0.303
    0.335
    0.370
    0.405
    0.437
    0.473
];

viscous_meas_neg = [
    0.219
    0.251
    0.286
    0.323
    0.360
    0.388
];

figure(1)
clf
hold on
plot(viscous_meas_pos, viscous_torques, 'o')
plot(viscous_meas_neg, viscous_torques, 'o')
colororder([0 0.447 0.741; 0.85 0.325 0.098])
title("Viscous Friction Measurements")
ylabel("Applied Torque [promille]")
ylim([0 35])
xlabel("Steady-state Velocity [m/s]")
xlim([0 0.5])

viscous_fit_pos = polyfit(viscous_meas_pos, viscous_torques, 1); 
viscous_fit_neg = polyfit(viscous_meas_neg, viscous_torques, 1);

plot([viscous_meas_pos(1) viscous_meas_pos(end)], viscous_fit_pos(2) + viscous_fit_pos(1) * [viscous_meas_pos(1) viscous_meas_pos(end)], '--')
plot([viscous_meas_neg(1) viscous_meas_neg(end)], viscous_fit_neg(2) + viscous_fit_neg(1) * [viscous_meas_neg(1) viscous_meas_neg(end)], '--')


viscous = mean([viscous_fit_pos(1) viscous_fit_neg(1)])
