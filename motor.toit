// import necessary libraries
import gpio.pwm as gpio
import gpio
import pubsub

// define PubSub topics
INCOMING_TOPIC ::= "cloud:motor/run"
OUTGOING_TOPIC ::= "cloud:motor/ack"

main:
  
  // Initialize PWM pins for motor control
  motor_pin_a := gpio.Pin 26 --output
  motor_pwm_a := gpio.Pwm --frequency=490
  motor_1a := motor_pwm_a.start motor_pin_a
  
  motor_pin_b := gpio.Pin 27 --output
  motor_pwm_b := gpio.Pwm --frequency=490
  motor_1b := motor_pwm_b.start motor_pin_b

  // Check for any new message on INCOMING_TOPIC
  pubsub.subscribe INCOMING_TOPIC --auto_acknowledge: | msg/pubsub.Message |
    print "Received: $msg.payload.to_string"
    
    // Split and separately save the direction and speed commands
    received_msg := msg.payload.to_string.split " "

    direction := received_msg[0]
    speed/float := 0.0

    // Check for direction and set the speed
    if direction == "stop":
      speed = 0.0
    else:
      speed = float.parse received_msg[1]

    if direction == "ccw":
      motor_1a.set_duty_factor speed
      motor_1b.set_duty_factor 0.0
    else if direction == "cw":
      motor_1a.set_duty_factor 0.0
      motor_1b.set_duty_factor speed
    else:
      motor_1a.set_duty_factor 0.0
      motor_1b.set_duty_factor 0.0

    // Send acknowledgement
    pubsub.publish OUTGOING_TOPIC "Done"

    