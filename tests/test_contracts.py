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

    def test_single_management_hierarchy_has_distinct_dev_and_prod_boundaries(self) -> None:
        tenant_template = self.read('infra/tenant/main.bicep')
        self.assertIn('developmentWorkloadManagementGroupName', tenant_template)
        self.assertIn('productionWorkloadManagementGroupName', tenant_template)
        self.assertEqual(2, tenant_template.count('id: workloadManagementGroup.id'))
        for environment in ('dev', 'prod'):
            parameters = self.read(f'infra/params/{environment}/tenant.bicepparam')
            self.assertIn("param rootManagementGroupName = 'reference-root'", parameters)
            self.assertIn("param developmentWorkloadManagementGroupName = 'reference-workloads-dev'", parameters)
            self.assertIn("param productionWorkloadManagementGroupName = 'reference-workloads-prod'", parameters)

    def test_dev_and_prod_policy_effects_are_intentionally_distinct(self) -> None:
        self.assertIn("param policyEffect = 'Audit'", self.read('infra/params/dev/management-group.bicepparam'))
        self.assertIn("param policyEffect = 'Deny'", self.read('infra/params/prod/management-group.bicepparam'))

    def test_policy_uses_supported_generic_tag_and_location_contracts(self) -> None:
        policy_template = self.read('infra/management-group/main.bicep')
        self.assertIn("Microsoft.Authorization/policyDefinitions@2023-04-01", policy_template)
        self.assertIn("field: '[concat(\\'tags[\\', parameters(\\'tagName\\'), \\']\\')]'", policy_template)
        self.assertIn("field: 'location'", policy_template)
        self.assertIn('public-network and diagnostic policies require separate alias validation', policy_template)

    def test_frozen_tag_contract_is_assigned_to_taggable_resources(self) -> None:
        policy_template = self.read('infra/management-group/main.bicep')
        subscription_template = self.read('infra/subscription/main.bicep')
        self.assertIn("mode: 'Indexed'", policy_template)
        self.assertIn('for tagName in requiredTagNames', policy_template)
        for environment in ('dev', 'prod'):
            parameters = self.read(f'infra/params/{environment}/management-group.bicepparam')
            for tag in ('environment', 'owner', 'costCenter', 'dataClassification'):
                self.assertIn(f"'{tag}'", parameters)
        self.assertNotIn('configured-by-parameter-file', subscription_template)
        for tag_parameter in ('environmentName', 'ownerTagValue', 'costCenterTagValue', 'dataClassificationTagValue'):
            self.assertIn(f'{tag_parameter} string', subscription_template)

    def test_network_parameters_represent_hub_and_distinct_dev_prod_spokes(self) -> None:
        template = self.read('infra/resource-group/main.bicep')
        platform_parameters = self.read('infra/params/platform/resource-group.bicepparam')
        dev_parameters = self.read('infra/params/dev/resource-group.bicepparam')
        prod_parameters = self.read('infra/params/prod/resource-group.bicepparam')
        self.assertIn("'Hub'", template)
        self.assertIn("'DevSpoke'", template)
        self.assertIn("'ProdSpoke'", template)
        self.assertIn("param networkRole = 'Hub'", platform_parameters)
        self.assertIn("param networkRole = 'DevSpoke'", dev_parameters)
        self.assertIn("param networkRole = 'ProdSpoke'", prod_parameters)
        self.assertIn("'10.10.0.0/16'", dev_parameters)
        self.assertIn("'10.20.0.0/16'", prod_parameters)
        for parameters in (platform_parameters, dev_parameters, prod_parameters):
            self.assertIn("'privatelink.blob.core.windows.net'", parameters)

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
