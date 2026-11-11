from __future__ import annotations

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
INFRA = ROOT / 'infra'


class ArchitectureContractTests(unittest.TestCase):
    def read(self, path: str) -> str:
        return (ROOT / path).read_text(encoding='utf-8')

    def test_entry_points_have_supported_declared_scopes(self) -> None:
        expected = {
            'infra/tenant/main.bicep': "targetScope = 'tenant'",
            'infra/management-group/main.bicep': "targetScope = 'managementGroup'",
            'infra/subscription/main.bicep': "targetScope = 'subscription'",
            'infra/resource-group/main.bicep': "targetScope = 'resourceGroup'",
        }
        for path, scope in expected.items():
            self.assertIn(scope, self.read(path))

    def test_tenant_entry_point_does_not_claim_subscription_provisioning(self) -> None:
        tenant_template = self.read('infra/tenant/main.bicep')
        self.assertIn('never provisions or moves them', tenant_template)
        self.assertNotIn('Microsoft.Subscription/aliases', tenant_template)

    def test_dev_and_prod_policy_effects_are_intentionally_distinct(self) -> None:
        self.assertIn("param policyEffect = 'Audit'", self.read('infra/params/dev/management-group.bicepparam'))
        self.assertIn("param policyEffect = 'Deny'", self.read('infra/params/prod/management-group.bicepparam'))

    def test_policy_uses_supported_generic_tag_and_location_contracts(self) -> None:
        policy_template = self.read('infra/management-group/main.bicep')
        self.assertIn("Microsoft.Authorization/policyDefinitions@2023-04-01", policy_template)
        self.assertIn("field: '[concat(\\'tags[\\', parameters(\\'tagName\\'), \\']\\')]'", policy_template)
        self.assertIn("field: 'location'", policy_template)
        self.assertIn('public-network and diagnostic policies require separate alias validation', policy_template)

    def test_parameter_examples_are_placeholders_not_real_identifiers(self) -> None:
        parameter_text = '\n'.join(path.read_text(encoding='utf-8') for path in (INFRA / 'params').rglob('*.bicepparam'))
        self.assertNotIn('/subscriptions/', parameter_text.lower())
        self.assertNotIn('tenantid', parameter_text.lower())
        self.assertIn('placeholder-principal-object-id', parameter_text)

    def test_no_github_actions_workflow_is_present(self) -> None:
        workflow_directory = ROOT / '.github' / 'workflows'
        self.assertFalse(workflow_directory.exists())

    def test_readme_states_local_validation_limit(self) -> None:
        readme = self.read('README.md')
        self.assertIn('not Azure deployment validation', readme)
        self.assertIn('not compliance certification', readme)


if __name__ == '__main__':
    unittest.main()
