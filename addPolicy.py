#!/usr/bin/env python3

import sys, os

path = sys.argv[1]

policyData = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
  "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
  "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>

  <action id="it.binbash.pkexec.salt">
    <message>Tranparent authentication for SALT</message>
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">{}</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>

</policyconfig>"""

if not os.path.isdir('/usr/share/polkit-1/actions'):
    print("The polkit directory does not exist/is not in the expected location. Please add the policy manually")
    exit()
if os.path.isfile('/usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy'):
    # Possibly an outdated version so we will remove it to be safe
    os.remove('/usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy')

with open('/usr/share/polkit-1/actions/it.binbash.pkexec.salt.policy','w') as policyFile:
    policyFile.write(policyData.format(path))
