install:
	python3 -m venv venv
	. venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

format:
	. venv/bin/activate && black *.py

train:
	. venv/bin/activate && python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	
	. venv/bin/activate && cml comment create report.md
		
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

hf-login: 
	python3 -m venv venv
	. venv/bin/activate && pip install -U "huggingface_hub[cli]"
	git pull origin update
	git switch update
	. venv/bin/activate && huggingface-cli login --token $(HF) --add-to-git-credential

push-hub: 
	. venv/bin/activate && huggingface-cli upload s24784/SUML-11c-GR1-CICD-ML ./App --repo-type=space --commit-message="Sync App files"
	. venv/bin/activate && huggingface-cli upload s24784/SUML-11c-GR1-CICD-ML ./Model /Model --repo-type=space --commit-message="Sync Model"
	. venv/bin/activate && huggingface-cli upload s24784/SUML-11c-GR1-CICD-ML ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub

all: install format train eval update-branch deploy