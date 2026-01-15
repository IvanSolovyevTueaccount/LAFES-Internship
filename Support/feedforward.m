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

B_pos = viscous_torques./viscous_meas_pos;
B_neg = viscous_torques./viscous_meas_neg;

figure(2)
clf
hold on
plot(viscous_torques,B_pos)
plot(viscous_torques,B_neg)
xlabel("Torque")
ylabel("B")
title("Friction coeffient for varying torques")

viscous = mean([viscous_fit_pos(1) viscous_fit_neg(1)])

%% Acceleration

size = 2000;
load("torque.mat")
load("reference.mat")
load("measured.mat")
Ts = acc_meas(1,2);

acc_measured = acc_meas(2,end-size+1:end);
acc_reference= acc_ref(2,end-size+1:end);
acc_torque_applied = smoothdata(acc_torque(2,end-size+1:end));

figure(3)
clf
hold on
plot(acc_reference)
plot(acc_measured)
plot(acc_torque_applied)
legend(["ref" "meas" "torque"])
title("Simulink Data")


acc_ref_vel = smoothdata(diff(acc_ref(2,:)) / Ts);
acc_ref_acc = smoothdata(diff(acc_ref_vel) / Ts);
acc_ref_vel = acc_ref_vel(end-size+1:end);
acc_ref_acc = acc_ref_acc(end-size+1:end);

figure(4)
clf 
hold on
title("Reference Inputs")
plot(acc_reference)
plot(acc_ref_vel)
plot(acc_ref_acc)
legend(["pos" "vel" "acc"])

acc_torque_acc = acc_torque_applied - 149 * sign(acc_ref_vel) - 146 * acc_ref_vel;

figure(5)
clf
hold on
plot(acc_ref_acc)
plot(acc_torque_acc)
legend(["ref acc" "t no ff"])
title("Torque Acceleration Relation")

I = sum(acc_torque_acc .* acc_ref_acc) / sum(acc_ref_acc .* acc_ref_acc)
