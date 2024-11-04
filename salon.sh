#! /bin/bash

PSQL='psql -X --username=freecodecamp --dbname=salon --tuples-only -c'

echo -e "\nSalon appointment scheduler"

SERVICES () {
    echo -e "\n$1"

    # show services
    SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services;")
    echo "$SERVICES_LIST" | while read SERVICE_ID PIPE NAME 
    do
      echo "$SERVICE_ID) $NAME"
    done

    # get service selected and check
    read SERVICE_ID_SELECTED

    SERVICE_EXISTS_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")

    if [[ -z $SERVICE_EXISTS_RESULT ]]
    then
      # go back to services
      SERVICES "Service not found. Please select a service."
    else 
      # get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE';")

      # phone number not found
      if [[ -z $CUSTOMER_ID ]] 
      then
        # get customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME

        # add customer
        CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE';")
        
      fi

      # get time
      echo -e "\nWhat time would you like to schedule your appointment?"
      read SERVICE_TIME

      # get name again
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = '$CUSTOMER_ID';")
      CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//')

      # insert appointment
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (name, time, customer_id, service_id) VALUES ('$CUSTOMER_NAME_FORMATTED', '$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED');")

      # confirm appointment
      if [[ -z $APPOINTMENT_RESULT ]] 
      then 
        # no appointment made
        echo -e "\nSomething went wrong with your appointment, please try again."
      else 
        # get service name
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
        SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//')

        # confirm appointment
        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
      fi

    fi

}

SERVICES "Which service would you like to schedule?"

# TODO: spaces round service name, time and customer name