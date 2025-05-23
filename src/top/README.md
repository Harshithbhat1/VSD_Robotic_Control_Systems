**Task 3**

Simulation of top module consisting of both I2C and 1 Dimensional Kalman filter

**Mathematical Equations for 1D kalman filter**

    Measurement: a

    State estimate: uh

    Measurement matrix: H

    Process noise covariance: q

    Measurement noise covariance: R

    Estimation error covariance: p

    Kalman gain: k

The filter update equations are:

    Kalman Gain Calculation:
    k=p*H/(H*P*H+R)

    State Estimate Update:
    uh=uh+k*(a−H*uh)

    Error Covariance Update:
    p=(1−k*H)*p+q
