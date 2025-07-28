# OpenVINS GPS-Enhanced System Architecture

## High-Level Overview

OpenVINS is a state-of-the-art filter-based visual-inertial estimator that has been extended to include GPS fusion capabilities. The system uses an Extended Kalman Filter (EKF) to fuse multi-modal sensor data for robust pose estimation.

### Core Components

1. **VioManager**: Central orchestrator managing the entire VIO pipeline
2. **State**: EKF state representation with IMU poses, features, and calibration parameters
3. **Propagator**: IMU-based state prediction and covariance propagation
4. **Trackers**: Visual feature tracking (KLT, descriptor-based, ArUco)
5. **Updaters**: Measurement updates (MSCKF, SLAM, GPS, Zero-velocity)
6. **ROS Interface**: Sensor data ingestion and result publication

### Sensor Fusion Architecture

The system processes three main sensor modalities:

#### 1. **IMU (Inertial Measurement Unit)**
- **Input**: Angular velocity (ωm) and linear acceleration (am) at ~200Hz
- **Processing**: 
  - Fed to both Propagator (for state prediction) and Initializer (for system startup)
  - Uses bias estimation and noise modeling
  - Supports both discrete and RK4 integration schemes
- **Role**: Primary motion model for state propagation

#### 2. **Camera (Monocular/Stereo)**
- **Input**: Grayscale images at ~20Hz from one or more cameras
- **Processing**:
  - Feature extraction using FAST corners with grid-based distribution
  - Temporal tracking via KLT optical flow or descriptor matching (ORB)
  - Stereo correspondence for depth estimation
  - Feature triangulation and management
- **Features Tracked**:
  - MSCKF features: Short-term tracks used in sliding window
  - SLAM features: Long-term landmarks maintained in state
  - ArUco markers: Artificial features for additional constraints

#### 3. **GPS (Global Positioning System)**
- **Input**: Longitude, latitude, altitude with covariance at ~1-10Hz
- **Processing**:
  - Coordinate transformation from LLA to local ENU frame
  - Position measurement updates with configurable noise models
  - Handles intermittent GPS availability
- **Role**: Global position constraints and drift correction

### Data Flow Pipeline

```
IMU Data → Propagator → State Prediction
                    ↓
Camera Data → Feature Tracking → MSCKF/SLAM Updates → State Correction
                                                   ↓
GPS Data → Coordinate Transform → GPS Update → Final State Estimate
```

## Key Architectural Features

### Multi-State Constraint Kalman Filter (MSCKF)
- Maintains sliding window of recent IMU poses as clones
- Features are triangulated and used for updates without being added to state
- Nullspace projection removes feature dependency from final system

### SLAM Feature Management
- Long-term features maintained in global coordinates
- Anchor-based representations for computational efficiency
- Dynamic feature initialization and marginalization

### Online Calibration
- Camera-IMU extrinsic calibration
- Camera intrinsic parameter refinement  
- Time offset estimation between sensors

### GPS Integration Enhancements
- Coordinate frame alignment between VIO and GPS
- Robust handling of GPS outages
- Position-only updates (ignoring altitude in 2D mode)

### Zero Velocity Updates (ZUPT)
- Detects stationary periods using IMU variance
- Provides velocity constraints during standstill
- Particularly useful for wheeled vehicles at stops

## Implementation Details

### State Vector
The EKF state contains:
- **IMU State**: Position, velocity, orientation, gyro bias, accel bias
- **Camera Clones**: Sliding window of recent poses for MSCKF
- **SLAM Features**: 3D landmark positions
- **Calibration**: Camera-IMU transforms, intrinsics, time offsets

### Update Pipeline
1. **Propagation**: IMU measurements drive state prediction
2. **Feature Tracking**: Extract and track visual features
3. **Triangulation**: Estimate 3D positions of tracked features
4. **MSCKF Update**: Use feature observations for pose correction
5. **SLAM Update**: Update long-term landmark estimates
6. **GPS Update**: Apply global position constraints
7. **Marginalization**: Remove old poses and features

### Robustness Features
- Chi-squared outlier rejection for measurements
- Feature track quality assessment
- Robust initialization from standstill
- Multi-threaded processing for computational efficiency

This architecture provides a comprehensive sensor fusion framework that leverages the complementary nature of visual, inertial, and GPS sensors for accurate and robust pose estimation in various environments.
