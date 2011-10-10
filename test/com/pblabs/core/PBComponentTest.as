package com.pblabs.core
{
    import flash.display.Stage;

    import mockolate.runner.MockolateRule;

    import com.pblabs.pb_internal;

    import org.hamcrest.assertThat;
    import org.hamcrest.object.notNullValue;

    use namespace pb_internal;

    public class PBComponentTest
    {
        [Rule]
        public var mockRule:MockolateRule = new MockolateRule();

        [Mock]
        public var stage:Stage;

        private var component:PBComponent;

        [Before(async)]
        public function setup():void
        {
            component = new PBComponent();
        }

        [Test]
        public function PBComponent_constructed():void
        {
            assertThat(component, notNullValue());
        }
    }
}