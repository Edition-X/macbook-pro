PYTHON_VIRTUAL_ENVIRONMENT := venv
PYTHON_REQUIREMENTS_FILE   := requirements.txt
ANSIBLE_PLAYBOOK_FILE      := site.yml

.DEFAULT_GOAL := $(PYTHON_VIRTUAL_ENVIRONMENT)

define activate
	(. $(PYTHON_VIRTUAL_ENVIRONMENT)/bin/activate && unset ANSIBLE_VAULT_PASSWORD_FILE && $1;)
endef

$(PYTHON_VIRTUAL_ENVIRONMENT): $(PYTHON_REQUIREMENTS_FILE)
	@python3 -m venv $(PYTHON_VIRTUAL_ENVIRONMENT)
	@$(call activate, pip install --upgrade pip)
	@$(call activate, pip install wheel)
	@$(call activate, pip install -r $(PYTHON_REQUIREMENTS_FILE))

.PHONY: apply
apply: $(PYTHON_VIRTUAL_ENVIRONMENT)
	@$(call activate, ansible-playbook $(ANSIBLE_PLAYBOOK_FILE) --skip-tags cleanup)

.PHONY: delete
delete: $(PYTHON_VIRTUAL_ENVIRONMENT)
	@$(call activate, ansible-playbook $(ANSIBLE_PLAYBOOK_FILE) --tags cleanup)

.PHONY: check
check: $(PYTHON_VIRTUAL_ENVIRONMENT)
	@$(call activate, ansible-playbook --check $(ANSIBLE_PLAYBOOK_FILE) $(RUN_ARGS))

.PHONY: clean
clean:
	-@rm -rf $(PYTHON_VIRTUAL_ENVIRONMENT)
