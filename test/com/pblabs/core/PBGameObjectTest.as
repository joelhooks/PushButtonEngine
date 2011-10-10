package com.pblabs.core
{
    import org.hamcrest.assertThat;
    import org.hamcrest.object.*;

    public class PBGameObjectTest
    {
        private static const GAME_OBJECT_NAME:String = "gameObject";
        private static const COMPONENT_NAME:String = "component";

        private var gameObject:PBGameObject;

        [Before]
        public function setup():void
        {
            gameObject = new PBGameObject( GAME_OBJECT_NAME );
        }

        [Test]
        public function PBGameObject_constructed():void
        {
            assertThat(gameObject, notNullValue());
        }

        [Test]
        public function name_whenConstructedWithNameParameter_nameEqualsParameter():void
        {
            assertThat(gameObject.name, equalTo(GAME_OBJECT_NAME));
        }

        [Test]
        public function deferring_whenSetToTrue_isTrue():void
        {
            gameObject.deferring = true;

            assertThat(gameObject.deferring, isTrue());
        }

        [Test]
        public function deferring_whenSetToFalse_isFalse():void
        {
            gameObject.deferring = false;

            assertThat(gameObject.deferring, isFalse());
        }

        [Test(expects="Error")]
        public function addComponent_whenCalledWithNullName_throwsError():void
        {
            var component:StubComponent = new StubComponent();

            gameObject.addComponent(component);
        }

        [Test]
        public function addComponent_setsComponentNameToNameArgument_nameIsEqualToArgument():void
        {
            var component:StubComponent = new StubComponent();

            gameObject.addComponent(component, COMPONENT_NAME);

            assertThat(component.name, equalTo(COMPONENT_NAME));
        }

        [Test]
        public function addComponent_initializesComponentWhenCalledWithNameArgument_initializedIsTrue():void
        {
            var component:StubComponent = new StubComponent();
            gameObject.deferring = false;
            gameObject.owningGroup = new StubGroup();

            gameObject.addComponent(component, COMPONENT_NAME);

            assertThat(component.initialized, isTrue());
        }

        [Test]
        public function addComponent_namedComponentInitializedWithoutNameArgument_initializedIsTrue():void
        {
            var component:StubComponent = new StubComponent();
            component.name = COMPONENT_NAME;
            gameObject.deferring = false;
            gameObject.owningGroup = new StubGroup();

            gameObject.addComponent(component);

            assertThat(component.initialized, isTrue());
        }

        [Test]
        public function addComponent_componentOwnerIsSet_ownerEqualsGroup():void
        {
            var component:StubComponent = new StubComponent();
            component.name = COMPONENT_NAME;
            gameObject.deferring = false;
            gameObject.owningGroup = new StubGroup();

            gameObject.addComponent(component);

            assertThat(component.owner, strictlyEqualTo(gameObject));
        }

        [Test]
        public function addComponent_gameObjectNamedPropertyIsSet_namedPropertyValueEqualsComponent():void
        {
            var component:StubComponent = new StubComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;

            gameObject.addComponent(component);

            assertThat(gameObject.component, strictlyEqualTo(component));
        }

        [Test]
        public function addComponent_whenDeferring_componentStoredMarkedAsDeferred():void
        {
            var component:StubComponent = new StubComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;
            gameObject.deferring = true;

            gameObject.addComponent(component);

            assertThat(gameObject.components["!" + COMPONENT_NAME], strictlyEqualTo(component));
        }

        [Test]
        public function addComponent_whenDeferring_componentIsNotInitialized():void
        {
            var component:StubComponent = new StubComponent();
            var gameObject:MockGameObject = new MockGameObject();
            component.name = COMPONENT_NAME;
            gameObject.deferring = true;

            gameObject.addComponent(component);

            assertThat(component.initialized, isFalse());
        }
    }
}

import com.pblabs.core.PBGameObject;

import flash.utils.Dictionary;

internal class MockGameObject extends PBGameObject
{
    public var component:Object;

    public function get components():Dictionary
    {
        return _components;
    }

    public function MockGameObject()
    {
        super("gameObject");
    }
}

import com.pblabs.core.PBComponent;
import com.pblabs.core.PBGroup;
import com.pblabs.pb_internal;

use namespace pb_internal

internal class StubComponent extends PBComponent
{
    public var added:Boolean;

    public function get initialized():Boolean
    {
        return owner && added;
    }

    override pb_internal function doAdd():void
    {
        added = true;
    }
}

/**
 * Mock class to break the dependency on the Injector for testing
 */
internal class StubGroup extends PBGroup
{
    override public function injectInto(object:*):void
    {
        //pass
    }
}