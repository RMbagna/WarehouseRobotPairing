from flask import Flask, request, jsonify
import csv
import os

app = Flask(__name__)

@app.route('/save_results', methods=['POST'])
def save_results():
    data = request.json

    # Check if the CSV file exists, and write headers if it doesn't
    file_exists = os.path.isfile('I4Game_results.csv')

    with open('I4Game_results.csv', 'a', newline='') as f:
        writer = csv.writer(f)
        # Write header only if the file did not exist before
        if not file_exists:
            writer.writerow(['trial_number', 'payoff_A_event1', 'payoff_A_event2',
                             'payoff_B_event1', 'payoff_B_event2', 'choice',
                             'chosen_payoff', 'current_amount', 'time_taken'])

        # Record the data
        row_data = [data['trial_number'], data['payoff_A_event1'], data['payoff_A_event2'],
                    data['payoff_B_event1'], data['payoff_B_event2'], data['choice'],
                    data['chosen_payoff'], data['current_amount'], data['time_taken']]
        
        writer.writerow(row_data)
        
        # Display the data in the terminal
        print("Data saved:", row_data)
    
    return jsonify({"status": "success"})

if __name__ == "__main__":
    app.run(debug=True)
