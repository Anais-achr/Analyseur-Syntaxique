import os
import subprocess
import sys

# Fonction pour exécuter une commande
def execute_command(command, file_name):
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except subprocess.CalledProcessError as e:
        error_message = e.stderr.decode('utf-8').strip() if e.stderr else "Erreur inconnue"
        print(f"Erreur dans '{file_name}': La commande a retourné {error_message}")
        return False
    return True

# Fonction pour exécuter les tests
def run_tests(test_directory, should_pass, option=""):
    total_tests = 0
    passed_tests = 0
    unexpected_results = []

    for test_file in os.listdir(test_directory):
        if test_file.endswith('.tpc'):
            total_tests += 1
            file_path = os.path.join(test_directory, test_file)
            command = f"bin/tpcas {option} < {file_path}"
            result = execute_command(command, test_file)
            if (result and should_pass) or (not result and not should_pass):
                passed_tests += 1
            else:
                unexpected_results.append(test_file)

    return passed_tests, total_tests, unexpected_results

# Vérifier si l'exécutable existe
if not os.path.exists('bin/tpcas'):
    print("Executable non trouvé. Exécution de 'make clean' et 'make'...")
    execute_command('make clean', '')
    execute_command('make', '')

# Demander à l'utilisateur de continuer avec les tests
user_input = input("Voulez-vous continuer avec les tests ? (y/n): ").lower()
if user_input not in ['y', 'yes']:
    sys.exit(0)

# Demander éventuellement des options supplémentaires
option = input("Entrez une option supplémentaire pour tpcas (ou laissez vide) : ")

# Exécuter les tests
print("Exécution des tests 'good'...")
good_passed, good_total, unexpected_good = run_tests('tests/good', True, option)
if good_passed == good_total:
    print("Good tests passed.....ok")
print("Exécution des tests 'bad'...")
bad_passed, bad_total, unexpected_bad = run_tests('tests/syn-err', False, option)
bad_score = (bad_passed / bad_total) * 100 if bad_total > 0 else 0
if bad_passed == bad_total:
    print("Bad tests passed.....ok")

# Calculer et afficher les scores
good_score = (good_passed / good_total) * 100 if good_total > 0 else 0
overall_score = ((good_passed + bad_passed) / (good_total + bad_total)) * 100 if (good_total + bad_total) > 0 else 0

print(f"\nScore des tests 'good' : {good_score}% ({good_passed}/{good_total})")
print(f"Score des tests 'bad' : {bad_score}% ({bad_passed}/{bad_total})")
print(f"Score global : {overall_score}%")

# Afficher les résultats inattendus
if unexpected_good:
    print("\nTests 'good' qui ont échoué de manière inattendue :")
    for test in unexpected_good:
        print(test)

if unexpected_bad:
    print("\nTests 'bad' qui ont réussi de manière inattendue :")
    for test in unexpected_bad:
        print(test)

if not unexpected_good and not unexpected_bad:
    print("\nTous les tests se sont comportés comme prévu.")
