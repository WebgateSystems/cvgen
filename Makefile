PROFILE ?= default
THEME ?=
LAYOUT ?=
CONTENT ?=
FIT ?=

.PHONY: cv validate profiles themes layouts content import

cv:
	bundle exec ruby bin/cv build --profile $(PROFILE) \
		$(if $(CONTENT),--content $(CONTENT),) \
		$(if $(THEME),--theme $(THEME),) \
		$(if $(LAYOUT),--layout $(LAYOUT),) \
		$(if $(FIT),--fit,)

interactive:
	bundle exec ruby bin/cv build -i

validate:
	bundle exec ruby bin/cv validate --profile $(PROFILE) $(if $(CONTENT),--content $(CONTENT),) $(if $(THEME),--theme $(THEME),)

profiles:
	bundle exec ruby bin/cv list-profiles

themes:
	bundle exec ruby bin/cv list-themes

layouts:
	bundle exec ruby bin/cv list-layouts

content:
	bundle exec ruby bin/cv list-content
