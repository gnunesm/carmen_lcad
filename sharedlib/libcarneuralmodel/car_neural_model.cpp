#include <carmen/carmen.h>
#include <fann.h>
#include <fann_train.h>
#include <fann_data.h>
#include <floatfann.h>
#include <pid.h>
#include "car_neural_model.h"


void
carmen_libcarneuralmodel_init_steering_ann_input(fann_type *input)
{
	int i;

	// steering = 0, current_curvature = 0
	for (i = 0; i < (NUM_STEERING_ANN_INPUTS - 1); i += 2)
	{
		input[i] = 0.0;
		input[i + 1] = 0.0;
	}
}


void
carmen_libcarneuralmodel_build_steering_ann_input(fann_type *input, double s, double cc, double v)
{
	int i;

	for (i = 0; i < (NUM_STEERING_ANN_INPUTS - 3); i++)
		input[i] = input[i + 3];

	input[NUM_STEERING_ANN_INPUTS - 3] = v / 100.0;
	input[NUM_STEERING_ANN_INPUTS - 2] = s / 100.0;
	input[NUM_STEERING_ANN_INPUTS - 1] = cc;
}


/* NAO ESTA FUNCIONANDO PQ TEM Q RETORNAR O fann_create_from_file
void
carmen_libcarneuralmodel_init_steering_ann (struct fann *steering_ann, fann_type *steering_ann_input)
{
	if (steering_ann == NULL)
	{
		steering_ann = fann_create_from_file("steering_ann.net");
		if (steering_ann == NULL)
		{
			printf("Error: Could not create steering_ann\n");
			exit(1);
		}
		carmen_libcarneuralmodel_init_steering_ann_input(steering_ann_input);
	}
}
*/


double
carmen_libcarneuralmodel_compute_new_phi_with_ann_PID(carmen_ackerman_traj_point_t current_robot_position, double v, double current_phi,
																double desired_phi, double time, double understeer_coeficient,
																double distance_between_front_and_rear_axles)
{
	static double steering_command = 0.0;
	double atan_current_curvature;
	double atan_desired_curvature;
	double new_phi;
	static fann_type steering_ann_input[NUM_STEERING_ANN_INPUTS];
	fann_type *steering_ann_output;
	static struct fann *steering_ann = NULL;

	if (steering_ann == NULL)
	{
		steering_ann = fann_create_from_file("steering_ann.net");
		if (steering_ann == NULL)
		{
			printf("Error: Could not create steering_ann\n");
			exit(1);
		}
		carmen_libcarneuralmodel_init_steering_ann_input(steering_ann_input);
	}

	atan_current_curvature = carmen_get_curvature_from_phi(current_phi, v, understeer_coeficient, distance_between_front_and_rear_axles);

	atan_desired_curvature = carmen_get_curvature_from_phi(desired_phi, v, understeer_coeficient, distance_between_front_and_rear_axles);

	carmen_libpid_steering_PID_controler(&steering_command, atan_desired_curvature,	atan_current_curvature, v, time);

	carmen_libcarneuralmodel_build_steering_ann_input(steering_ann_input, steering_command, atan_current_curvature, v);

	steering_ann_output = fann_run(steering_ann, steering_ann_input);

	new_phi = carmen_get_phi_from_curvature(tan(steering_ann_output[0]), v, understeer_coeficient, distance_between_front_and_rear_axles);

	return (new_phi);
}


void
carmen_libcarneuralmodel_init_velocity_ann_input(fann_type *input)
{
	int i;

	// acelerador = 0, freio = 100.0, v = 0.0
	for (i = 0; i < (NUM_VELOCITY_ANN_INPUTS - 1); i += 3)
	{
		input[i] = 0.0;
		input[i + 1] = 100.0 / 100.0;
		input[i + 2] = 0.0;
	}
}


void
carmen_libcarneuralmodel_build_velocity_ann_input(fann_type *input, double t, double b, double cv)
{
	int i;

	for (i = 0; i < (NUM_VELOCITY_ANN_INPUTS - 3); i++)
		input[i] = input[i + 3];

	input[NUM_VELOCITY_ANN_INPUTS - 3] = t / 100.0;
	input[NUM_VELOCITY_ANN_INPUTS - 2] = b / 100.0;
	input[NUM_VELOCITY_ANN_INPUTS - 1] = cv / 5.0;
}


double
carmen_libcarneuralmodel_compute_new_velocity_with_ann_PID(carmen_ackerman_traj_point_t current_robot_position, double desired_v, double v, double current_phi,
														double desired_phi, double time, double understeer_coeficient,
														double distance_between_front_and_rear_axles)
{
	static double throttle_command = 0.0;
	static double brakes_command = 100.0 / 100.0;
	static int gear_command = 0;
	static fann_type velocity_ann_input[NUM_VELOCITY_ANN_INPUTS];
	fann_type *velocity_ann_output;
	static struct fann *velocity_ann = NULL;
	double next_velocity;

	if (velocity_ann == NULL)
	{
		velocity_ann = fann_create_from_file("velocity_ann.net");
		if (velocity_ann == NULL)
		{
			printf("Error: Could not create velocity_ann\n");
			exit(1);
		}
		carmen_libcarneuralmodel_init_velocity_ann_input(velocity_ann_input);
	}

	carmen_libpid_velocity_PID_controler(&throttle_command, &brakes_command, &gear_command, desired_v, v, time);

	if (gear_command == 129) // marcha reh
	{
		carmen_libcarneuralmodel_build_velocity_ann_input(velocity_ann_input, throttle_command, brakes_command, -v);
		velocity_ann_output = fann_run(velocity_ann, velocity_ann_input);

		next_velocity = velocity_ann_output[0];
	}
	else
	{
		carmen_libcarneuralmodel_build_velocity_ann_input(velocity_ann_input, throttle_command, brakes_command, v);
		velocity_ann_output = fann_run(velocity_ann, velocity_ann_input);

		next_velocity = velocity_ann_output[0];
	}
	next_velocity = next_velocity + next_velocity * carmen_gaussian_random(0.0, 0.007); // add some noise

	return (next_velocity);
}

