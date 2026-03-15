"""
Sample unit tests for test-agents project
"""

import unittest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


class TestSample(unittest.TestCase):
    """Basic test cases for test-agents"""

    def test_imports(self):
        """Test that required modules can be imported"""
        try:
            import boto3
            import requests
            import yaml
            self.assertTrue(True)
        except ImportError as e:
            self.fail(f"Failed to import required module: {e}")

    def test_environment_variables(self):
        """Test that environment can be set up"""
        os.environ['TEST_VAR'] = 'test_value'
        self.assertEqual(os.environ.get('TEST_VAR'), 'test_value')

    def test_basic_arithmetic(self):
        """Test basic functionality"""
        self.assertEqual(1 + 1, 2)
        self.assertEqual(5 - 3, 2)
        self.assertEqual(2 * 3, 6)

    def test_string_operations(self):
        """Test string operations"""
        test_string = "test-agents"
        self.assertIn("test", test_string)
        self.assertEqual(test_string.upper(), "TEST-AGENTS")


class TestCloudFormationIntegration(unittest.TestCase):
    """Test CloudFormation template integration"""

    def test_template_exists(self):
        """Test that CloudFormation template exists"""
        template_path = os.path.join(
            os.path.dirname(__file__), '..', 'cloudformation', 'template.yaml'
        )
        self.assertTrue(os.path.exists(template_path), 
                       f"Template file not found: {template_path}")

    def test_template_is_valid_yaml(self):
        """Test that CloudFormation template is valid YAML"""
        try:
            import yaml
            template_path = os.path.join(
                os.path.dirname(__file__), '..', 'cloudformation', 'template.yaml'
            )
            with open(template_path, 'r') as f:
                yaml.safe_load(f)
            self.assertTrue(True)
        except Exception as e:
            self.fail(f"Template YAML validation failed: {e}")


if __name__ == '__main__':
    unittest.main()
