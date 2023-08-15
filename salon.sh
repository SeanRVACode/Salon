#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~\n"

  echo -e  "\nWelcome to My Salon, how can I help you?\n"

SERVICE_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Get salon services
  SERVICES_RESULTS=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id;")
  if [[ -z $SERVICES_RESULTS ]]
  then
    # Return them to the main menu 
    SERVICE_MENU "We currently don't have any services"
  else
    echo "$SERVICES_RESULTS" | while read SERVICE_ID BAR NAME BAR
    do
      echo "$SERVICE_ID) $NAME"
    done

    # Ask which service they want
    read SERVICE_ID_SELECTED

    # If service requested is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # Return to Service Menu
      SERVICE_MENU "I could not find that service. What would you like today?"
    else
      # Check if service exist
      SERVICE_EXIST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
      if [[ -z $SERVICE_EXIST ]]
      then
        # Service did not exist
        SERVICE_MENU "I could not find that service. What would you like today?"
      else
        # Get phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        # Get customer Info
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")


        # If Customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # Insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE');")
        fi
        # Get the time for their appointment
        echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
        read SERVICE_TIME

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id,customer_id,time) VALUES($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME');")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')


        SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //')

        echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED." 
      fi
    fi
  fi
}

SERVICE_MENU
